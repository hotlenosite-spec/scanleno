# Firebase Auth and Firestore metadata

ScanLeno uses Firebase for accounts only.

Allowed:

- Firebase Authentication providers: Anonymous, Email/Password, Google, Apple.
- Firestore collection: `users/{uid}` for account and subscription metadata.

Not allowed:

- Firebase Storage.
- User PDFs, images, OCR images, document text, document contents, or local file paths in Firestore.
- Collections for user documents.

Allowed `users/{uid}` metadata fields:

- `uid`
- `email`
- `displayName`
- `photoUrl`
- `provider`
- `isAnonymous`
- `plan`
- `premiumActive`
- `premiumExpiresAt`
- `platform`
- `monthlyOcrUsed`
- `monthlyOcrLimit`
- `scanCredit`
- `createdAt`
- `updatedAt`
- `lastLoginAt`
- `disabled`
- `role`

Security rules are provided in `firebase/firestore.rules`.

Users can read only their own metadata. Admin and owner users can read and update administrative metadata. Regular users cannot update `plan`, `premiumActive`, `premiumExpiresAt`, `monthlyOcrLimit`, `scanCredit`, `role`, or `disabled`.
