.pragma library

// var constants = {
//     _1microsecond: 1,
// }

var components = {
    workoutEditPageComponent: undefined,
    editWorkoutSettingsComponent: undefined,
    entryEditPageComponent: undefined,
    workoutPerformancePageComponent: undefined,

    setWorkoutEditPageComponent: function(obj) {
        this.workoutEditPageComponent = obj
    },

    setEditWorkoutSettingsComponent: function(obj) {
        this.editWorkoutSettingsComponent = obj
    },

    setEntryEditPageComponent: function(obj) {
        this.entryEditPageComponent = obj
    },

    setWorkoutPerformancePageComponent: function(obj) {
        this.workoutPerformancePageComponent = obj
    }
}

// var config = {
//     // user preferences
//     maxNumberOfRecents: 5,

//     // Array objects holding recent opened keepass databases.
//     // The full path to the database and keyfile must be set.
//     // Every database entry has a keyfile entry. If no keyfile exists for a database
//     // the keyfile entry must be an empty string "".
//     recentDbNamesUI: undefined,
//     recentDbPathsUI: undefined,
//     recentDbLocations: undefined,
//     recentDbFilePaths: undefined,
//     recentUseKeyFiles: undefined,
//     recentKeyFileLocations: undefined,
//     recentKeyFilePaths: undefined,

//     // initialize arrays
//     initArrays: function() {
//         this.recentDbNamesUI = []
//         this.recentDbPathsUI = []
//         this.recentDbLocations = []
//         this.recentDbFilePaths = []
//         this.recentUseKeyFiles = []
//         this.recentKeyFileLocations = []
//         this.recentKeyFilePaths = []
//     },

//     // return amount of recently opened database
//     getNumberOfRecents: function() {
//         if (this.recentDbNamesUI === undefined) {
//             this.initArrays()
//         }
//         // check if all lengths are equal otherwise clean everything up
//         var length = this.recentDbNamesUI.length
//         if (
//                 (this.recentDbPathsUI.length === length) &&
//                 (this.recentDbLocations.length === length ) &&
//                 (this.recentDbFilePaths.length === length) &&
//                 (this.recentUseKeyFiles.length === length) &&
//                 (this.recentKeyFileLocations.length === length ) &&
//                 (this.recentKeyFilePaths.length === length))
//         {
//             return length
//         } else {
//             this.initArrays()
//             return 0
//         }
//     },

//     deleteDbFromRecentList: function(index) {
//         if (index >= this.getNumberOfRecents()) {
//             this.recentDbNamesUI.splice(index, 1)
//             this.recentDbPathsUI.splice(index, 1)
//             this.recentDbLocations.splice(index, 1)
//             this.recentDbFilePaths.splice(index, 1)
//             this.recentUseKeyFiles.splice(index, 1)
//             this.recentKeyFileLocations.splice(index, 1)
//             this.recentKeyFilePaths.splice(index, 1)
//         }
//     },

//     //
//     addNewRecent: function(databaseLocation, database, useKeyFile, keyFileLocation, keyFile) {
//         // check if input is valid
//         if (database === undefined) {
//             console.log("Database undefined in addNewRecent()")
//             return false
//         }
//         if (keyFile === undefined) {
//             keyFile = "/"
//         }
//         // check if new database is already in the recent list and remove it before adding
//         var index = this.recentDbFilePaths.indexOf(database)
//         if (index !== -1) {
//             this.recentDbNamesUI.splice(index, 1)
//             this.recentDbPathsUI.splice(index, 1)
//             this.recentDbLocations.splice(index, 1)
//             this.recentDbFilePaths.splice(index, 1)
//             this.recentUseKeyFiles.splice(index, 1)
//             this.recentKeyFileLocations.splice(index, 1)
//             this.recentKeyFilePaths.splice(index, 1)
//         }
//         // check if more than max recent entries are already in the list and remove the oldest
//         while (this.getNumberOfRecents() >= this.maxNumberOfRecents) {
//             this.recentDbNamesUI.pop()
//             this.recentDbPathsUI.pop()
//             this.recentDbLocations.pop()
//             this.recentDbFilePaths.pop()
//             this.recentUseKeyFiles.pop()
//             this.recentKeyFileLocations.pop()
//             this.recentKeyFilePaths.pop()
//         }
//         // cut name and path from database file path and save separately
//         this.recentDbNamesUI.unshift(database.substring(database.lastIndexOf("/") + 1, database.length))
//         this.recentDbPathsUI.unshift(database.substring(0, database.lastIndexOf("/") + 1))
//         // add new keepass database/keyfile entry
//         this.recentDbLocations.unshift(databaseLocation)
//         this.recentDbFilePaths.unshift(database)
//         this.recentUseKeyFiles.unshift(useKeyFile)
//         this.recentKeyFileLocations.unshift(keyFileLocation)
//         this.recentKeyFilePaths.unshift(keyFile)
//         return true
//     }

// }

