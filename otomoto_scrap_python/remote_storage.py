
import firebase_admin
from firebase_admin import firestore
from datetime import datetime

from firebase_admin import credentials
from local_storage import LocalStorage

class RemoteStorage:

    __db = None
    __carsCollection = "cars"
    __metadataCollection = "metadata"

    __existingIds = []

    def __init__(self): 
        cred = credentials.Certificate("")
        firebase_admin.initialize_app(cred)
        self.__db = firestore.client()
    
    def close(self):
        # not used in firestore
        pass

    def startTransaction(self):
        # not used in firestore
        pass

    def commitTransaction(self):
        # not used in firestore
        pass

    def addRecord(self, createdAt, externalId, url, price, currency, fuelType, gearbox, enginePower, year, countryOrigin, mileage):
        # avoid duplicates
        if self.__checkIfIdExists(externalId):
            return
        print(f"NEW externalId: {externalId}")
        self.__db.collection(self.__carsCollection).add({
            "createdAt": datetime.strptime(createdAt, "%Y-%m-%d %H:%M:%S"),
            "externalId": externalId, 
            "url": url, 
            "price": price, 
            "currency": currency, 
            "fuelType": fuelType, 
            "gearbox": gearbox, 
            "enginePower": enginePower, 
            "year": year, 
            "countryOrigin": countryOrigin, 
            "mileage": mileage
        })
        self.__appendExternalId([externalId])

    def select(self):
        idsStream = self.__db.collection(self.__idsCollection).stream()
        existingIds = [doc.to_dict()["externalId"] for doc in idsStream]
        print(len(existingIds))

    def fetchLastCreatedAt(self):
        query = db.collection(self.__carsCollection).order_by("createdAt", direction=firestore.Query.DESCENDING).limit(1)
        docs = query.stream()
        for doc in docs:
            return doc.to_dict()["createdAt"]

    def importFromLocal(self):
        localStorage = LocalStorage()
        rows = localStorage.select()
        externalIds = []
        for row in rows:
            self.__db.collection(self.__carsCollection).add({
                "externalId": row[1], 
                "createdAt": datetime.strptime(row[2], "%Y-%m-%d %H:%M:%S"),
                "url": row[3], 
                "price": row[4], 
                "currency": row[5], 
                "fuelType": row[6], 
                "gearbox": row[7], 
                "enginePower": row[8], 
                "year": row[9], 
                "countryOrigin": row[10], 
                "mileage": row[11]
            })
        self.__appendExternalId(externalIds)

    def __checkIfIdExists(self, externalId):
        metadata = self.__db.collection(self.__metadataCollection).document("ids")
        result = metadata.where("ids", "array-contains", externalId).get()
        return result == True

    def __appendExternalId(self, externalIds):
        metadata = self.__db.collection(self.__metadataCollection).document("ids")
        metadata_ref.update({"ids": firestore.ArrayUnion(externalIds)})

if __name__ == "__main__":
    RemoteStorage().importFromLocal()