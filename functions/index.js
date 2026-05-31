const admin = require("firebase-admin");
const functions = require("firebase-functions");
const { onSchedule } = require("firebase-functions/v2/scheduler");

admin.initializeApp();

const BRAZIL_TIME_ZONE = "America/Sao_Paulo";
const REMINDER_SLOTS = {
  noon: {
    schedule: "0 12 * * *",
    label: "12:00",
  },
  evening: {
    schedule: "0 18 * * *",
    label: "18:00",
  },
};

function getBrazilDayKey(date = new Date()) {
  return formatBrazilDayKey(date);
}

function formatBrazilDayKey(date) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: BRAZIL_TIME_ZONE,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(date);
}

function toDateValue(value) {
  if (!value) {
    return null;
  }

  if (typeof value.toDate === "function") {
    return value.toDate();
  }

  return value instanceof Date ? value : null;
}

function getUserCheckInDayKey(userData) {
  const checkInDate = toDateValue(userData.last_check_in_date);
  return checkInDate ? formatBrazilDayKey(checkInDate) : null;
}

function hasReminderBeenSent(userData, slotKey, dayKey) {
  const reminderSlots = userData.last_checkin_reminder_sent_slots || {};
  return reminderSlots[slotKey] === dayKey;
}

async function removeInvalidTokens(userDoc, tokens, response) {
  const tokensToRemove = [];

  response.responses.forEach((res, index) => {
    if (!res.success) {
      console.log(
        `Failed to send to token ${tokens[index]}: ${res.error?.code} - ${res.error?.message}`,
      );

      const code = res.error?.code || "";
      if (
        code === "messaging/registration-token-not-registered" ||
        code === "messaging/invalid-registration-token"
      ) {
        tokensToRemove.push(tokens[index]);
      }
    }
  });

  if (tokensToRemove.length > 0) {
    await userDoc.ref.update({
      fcm_tokens: admin.firestore.FieldValue.arrayRemove(...tokensToRemove),
    });
  }
}

async function sendCheckInReminders(slotKey) {
  const slot = REMINDER_SLOTS[slotKey];
  const todayKey = getBrazilDayKey();
  const firestore = admin.firestore();
  const usersSnapshot = await firestore.collection("users").get();

  if (usersSnapshot.empty) {
    console.log(`No users found for reminder slot ${slot.label}.`);
    return null;
  }

  let eligibleUsers = 0;
  let sentNotifications = 0;

  for (const userDoc of usersSnapshot.docs) {
    const userData = userDoc.data() || {};
    const tokens = Array.isArray(userData.fcm_tokens)
      ? userData.fcm_tokens.filter((token) => typeof token === "string" && token.trim().length > 0)
      : [];

    if (tokens.length === 0) {
      continue;
    }

    const userCheckInDayKey = getUserCheckInDayKey(userData);
    if (userCheckInDayKey === todayKey) {
      continue;
    }

    if (hasReminderBeenSent(userData, slotKey, todayKey)) {
      continue;
    }

    eligibleUsers += 1;

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: "Hora do check-in",
        body: "Ei! Ainda dá tempo de fazer seu check-in de hoje. Seu apoio faz diferença.",
      },
      data: {
        type: "daily_check_in_reminder",
        slot: slot.label,
        reminderDate: todayKey,
      },
    });

    sentNotifications += response.successCount;

    await userDoc.ref.update({
      [`last_checkin_reminder_sent_slots.${slotKey}`]: todayKey,
      last_checkin_reminder_sent_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    await removeInvalidTokens(userDoc, tokens, response);
  }

  console.log(
    `Reminder slot ${slot.label} processed. Eligible users: ${eligibleUsers}, successful notifications: ${sentNotifications}.`,
  );

  return null;
}

exports.sendDailyCheckInRemindersAtNoon = onSchedule(
  {
    schedule: REMINDER_SLOTS.noon.schedule,
    timeZone: BRAZIL_TIME_ZONE,
    region: "southamerica-east1",
  },
  async () => sendCheckInReminders("noon"),
);

exports.sendDailyCheckInRemindersAtEvening = onSchedule(
  {
    schedule: REMINDER_SLOTS.evening.schedule,
    timeZone: BRAZIL_TIME_ZONE,
    region: "southamerica-east1",
  },
  async () => sendCheckInReminders("evening"),
);

exports.onInvitationCreated = functions
  .region("southamerica-east1")
  .firestore.document("invitations/{invitationId}")
  .onCreate(async (snapshot, context) => {
    const invitation = snapshot.data() || {};
    const recipientEmail = invitation.recipient;
    const groupId = invitation.group;

    if (!recipientEmail || !groupId) {
      console.log("Invitation missing recipient or group.");
      return null;
    }

    const userSnapshot = await admin
      .firestore()
      .collection("users")
      .where("email", "==", recipientEmail)
      .limit(1)
      .get();

    if (userSnapshot.empty) {
      console.log("Recipient user not found.");
      return null;
    }

    const userDoc = userSnapshot.docs[0];
    const tokens = userDoc.get("fcm_tokens") || [];

    console.log(`User ${recipientEmail} has ${tokens.length} tokens:`, tokens);

    if (!Array.isArray(tokens) || tokens.length === 0) {
      console.log(`Recipient ${recipientEmail} has no FCM tokens.`);
      return null;
    }

    const groupInfoDoc = await admin
      .firestore()
      .collection("groups")
      .doc(groupId)
      .collection("info")
      .doc("info")
      .get();

    const groupName = groupInfoDoc.exists
      ? groupInfoDoc.get("title") || "grupo"
      : "grupo";
    const sender = invitation.sender || "Alguém";

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: "Convite para grupo",
        body: `${sender} convidou você para ${groupName}.`,
      },
      data: {
        type: "group_invitation",
        invitationId: context.params.invitationId,
        groupId,
      },
    });

    console.log(`Notification sent to ${tokens.length} tokens. Success: ${response.successCount}, Failure: ${response.failureCount}`);

    const tokensToRemove = [];
    response.responses.forEach((res, index) => {
      if (!res.success) {
        console.log(`Failed to send to token ${tokens[index]}: ${res.error?.code} - ${res.error?.message}`);
        const code = res.error?.code || "";
        if (
          code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token"
        ) {
          tokensToRemove.push(tokens[index]);
        }
      }
    });

    if (tokensToRemove.length > 0) {
      await userDoc.ref.update({
        fcm_tokens: admin.firestore.FieldValue.arrayRemove(...tokensToRemove),
      });
    }

    return null;
  });
