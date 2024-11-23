import requests
import sqlite3
import json

class Storage:
    
    __connection = None
    __transactionCursor = None
    __dbFile = "/Users/dariusz.baranczuk/Downloads/otomoto.db"

    def __init__(self): 
        self.__connectDb()
        self.__createTable()

    def __connectDb(self):
        self.__connection = sqlite3.connect(self.__dbFile)
    
    def close(self):
        self.commitTransaction()
        self.__connection.close()

    def __createTable(self):
        cursor = self.__connection.cursor()
        cursor.execute('''
CREATE TABLE IF NOT EXISTS cars (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    externalId INTEGER NOT NULL UNIQUE,
    url TEXT,
    price DOUBLE,
    currency TEXT,
    fuelType TEXT,
    gearbox TEXT,
    enginePower INTEGER,
    year INTEGER,
    countryOrigin TEXT,
    mileage INTEGER
)
''')
        cursor.close()

    def startTransaction(self):
        self.__transactionCursor = self.__connection.cursor()

    def commitTransaction(self):
        self.__connection.commit()
        if self.__transactionCursor:
            self.__transactionCursor.close()

    def addRecord(self, externalId, url, price, currency, fuelType, gearbox, enginePower, year, countryOrigin, mileage):

        self.__transactionCursor.execute('''
INSERT OR IGNORE INTO cars (externalId, url, price, currency, fuelType, gearbox, enginePower, year, countryOrigin, mileage)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
''', (externalId, url, price, currency, fuelType, gearbox, enginePower, year, countryOrigin, mileage))

    def select(self):
        cursor = self.__connection.cursor()
        cursor.execute("SELECT * FROM cars")
        rows = cursor.fetchall()
        print(f"{'ID':<5} {'External ID':<15} {'Price':<10} {'Currency':<10} {'Fuel Type':<15} {'Gearbox':<10} {'Engine Power':<15} {'Year':<5} {'Country Origin':<15} {'Mileage':<10}")
        print("-" * 157)

        for row in rows:
            formatted_row = [str(col) if col is not None else "" for col in row]
            print(f"{formatted_row[0]:<5} {formatted_row[1]:<15} {formatted_row[3]:<10} {formatted_row[4]:<10} {formatted_row[5]:<15} {formatted_row[6]:<10} {formatted_row[7]:<15} {formatted_row[8]:<5} {formatted_row[9]:<15} {formatted_row[10]:<10}")

        cursor.close()

class OtomotoScrap:

    __url = 'https://www.otomoto.pl/graphql'
    __headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:132.0) Gecko/20100101 Firefox/132.0",
        "Accept": "application/graphql-response+json, application/graphql+json, application/json, text/event-stream, multipart/mixed",
        "Accept-Language": "en-US,en;q=0.5",
        "Accept-Encoding": "gzip, deflate, br, zstd",
        "content-type": "application/json",
    }

    __storage = Storage()

    def print(self):
        self.__storage.select()

    def scrap(self):
        print("Start")

        with open("request.json", "r") as file:
            requestData = json.load(file)

        page = 1

        while True:
            # update page in request data
            requestData["variables"]["page"] = page

            response = requests.post(self.__url, json = requestData, headers = self.__headers)
            jsonData = response.json()["data"]["advertSearch"]
            
            totalCount = jsonData["totalCount"]
            pageSize = jsonData["pageInfo"]["pageSize"]
            currentOffset = jsonData["pageInfo"]["currentOffset"]

            print(f"Read page {page}")

            self.__storage.startTransaction()
            self.__readContents(jsonData)
            self.__storage.commitTransaction()

            page = page + 1
            if currentOffset + pageSize > totalCount:
                break

        print("Done!")
            
        self.__storage.close()
    
    def __readContents(self, json):
        nodes = json["edges"]
        for nodeWrapper in nodes:
            node = nodeWrapper["node"]
            id = node["id"]
            url = node["url"]
            price = node["price"]["amount"]["value"]
            currency = node["price"]["amount"]["currencyCode"]
            
            parameters = node["parameters"]
            fuelType = self.__readParameter(parameters, "fuel_type")
            gearBox = self.__readParameter(parameters, "gearbox")
            enginePower = self.__readParameter(parameters, "engine_power")
            year = self.__readParameter(parameters, "year")
            countryOrigin = self.__readParameter(parameters, "country_origin")
            mileage = self.__readParameter(parameters, "mileage")

            self.__storage.addRecord(id, url, price, currency, fuelType, gearBox, enginePower, year, countryOrigin, mileage)

    def __readParameter(self, parameters, key):
        return next((param["value"] for param in parameters if param["key"] == key), None)

OtomotoScrap().print()