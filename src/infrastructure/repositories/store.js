class FirestoreHandler {
  constructor(db, storage) {
    this.db = db; // Firestore instance
    this.storage = storage; // Firebase Storage instance
  }

  /**
   * Read documents from a Firestore collection.
   *
   * @param {string} collection - The Firestore collection name.
   * @param {string|null} [identifier=null] - Optional document identifier.
   * @param {Array|null} [filters=null] - Optional list of filters as tuples [field, operator, value].
   * @return {Promise<Array>} - List of documents as objects.
   */
  async read(collection, identifier = null, filters = null) {
    const collectionRef = this.db.collection(collection);

    if (identifier) {
      const doc = await collectionRef.doc(identifier).get();
      return doc.exists ? [doc.data()] : [];
    }

    let query = collectionRef;
    if (filters) {
      for (const [field, operator, value] of filters) {
        query = query.where(field, operator, value);
      }
    }

    const querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => doc.data());
  }

  /**
   * Write new documents to a Firestore collection.
   *
   * @param {string} collection - The Firestore collection name.
   * @param {Object|Array} data - A single document or an array of documents to write.
   * @throws {Error} - If data does not meet the required structure or has duplicate tags.
   */
  async write(collection, data) {
    const collectionRef = this.db.collection(collection);
    const batch = this.db.batch();

    const documents = Array.isArray(data) ? data : [data];
    const documentTagsSeen = new Set();

    for (const document of documents) {
      const documentTag = document.document_tag;
      const contents = document.contents;

      if (!documentTag || !contents) {
        throw new Error("Each document must have 'document_tag' and 'contents'.");
      }

      if (documentTagsSeen.has(documentTag)) {
        throw new Error(`Duplicate document tag '${documentTag}'`);
      }

      documentTagsSeen.add(documentTag);
      const docRef = collectionRef.doc(documentTag);

      const docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        throw new Error(`Document '${documentTag}' already exists`);
      }

      batch.set(docRef, contents);
    }

    await batch.commit();
    return true;
  }

  /**
   * Read multimedia content using URLs stored in Firestore.
   *
   * @param {string} collection - The Firestore collection name.
   * @param {string|null} [identifier=null] - Optional document identifier.
   * @param {string} urlField - The attribute in Firestore that stores the Storage URL.
   * @return {Promise<Array>} - List of multimedia content data (e.g., blobs or base64 strings).
   */
  async readMultimedia(collection, identifier = null, urlField) {
    const documents = await this.read(collection, identifier);
    const multimediaData = [];

    for (const doc of documents) {
      const fileUrl = doc[urlField];
      if (fileUrl) {
        const fileRef = this.storage.refFromURL(fileUrl);
        const fileBlob = await fileRef.getDownloadURL()
          .then(async (url) => {
            const response = await fetch(url);
            return await response.blob();
          });

        multimediaData.push({
          metadata: doc,
          content: fileBlob,
        });
      }
    }

    return multimediaData;
  }
}
