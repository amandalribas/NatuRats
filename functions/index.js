const admin = require("firebase-admin");
const functions = require("firebase-functions");

admin.initializeApp();

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
