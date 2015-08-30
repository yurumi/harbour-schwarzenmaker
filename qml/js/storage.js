.import QtQuick.LocalStorage 2.0 as Sql

function getDatabase() {
    return Sql.LocalStorage.openDatabaseSync("SchwarzenmakerDb", "1.0", "Schwarzenmaker Workout Database", 1000000);
    //return openDatabaseSync("SchwarzenmakerDb", "1.0", "Schwarzenmaker Workout Database", 1000000);
}

function initializeDatabase() {
    var db = getDatabase();

    ////////////////////////////////
    // create settings table
    ////////////////////////////////
    // db.transaction(
    // 		   function(tx) {
    // 		       var query="DROP TABLE settings;";
    // 		       tx.executeSql(query);
    // 		   });

    db.transaction(
		   function(tx) {
		       var query="CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE ON CONFLICT IGNORE, value TEXT);";
		       tx.executeSql(query);
		   });

    // create options in settings table
    db.transaction(
		   function(tx) {
		       var query="INSERT INTO settings VALUES('AudibleTimerEnabled', 'true');";
		       tx.executeSql(query);
		   });

    db.transaction(
		   function(tx) {
		       var query="INSERT INTO settings VALUES('AudibleTimerNumEvents', '3');";
		       tx.executeSql(query);
		   });

    db.transaction(
		   function(tx) {
		       var query="INSERT INTO settings VALUES('DefaultPauseDuration', '20');";
		       tx.executeSql(query);
		   });

    db.transaction(
		   function(tx) {
		       var query="INSERT INTO settings VALUES('DefaultExcerciseDuration', '30');";
		       tx.executeSql(query);
		   });

    ////////////////////////////////
    // create table of contents
    ////////////////////////////////
    db.transaction(
		   function(tx) {
		       var query="CREATE TABLE IF NOT EXISTS toc(wid INTEGER UNIQUE PRIMARY KEY ON CONFLICT IGNORE, wtitle TEXT);";
		       tx.executeSql(query);
		   });
}

function printWorkout(wid) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT * FROM workout_" + wid + ";");
        for(var i = 0; i < rs.rows.length; i++) {
            var dbItem = rs.rows.item(i);
            console.log("IID: " + dbItem.iid + " Title: " + dbItem.title + " Type: " + dbItem.type + " Duration: " + dbItem.duration + " Desc: " + dbItem.description);
        }
    });
}

function printTables() {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;");
        for(var i = 0; i < rs.rows.length; i++) {
            var dbItem = rs.rows.item(i);
            console.log("Name: " + dbItem.name);
        }
    });
}

function getSetting(setting) {
    var db = getDatabase();
    var ret = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting]);
        if (rs.rows.length > 0) {
            ret = rs.rows.item(0).value;
        } else {
            ret = "Unknown";
        }
    })

    return ret
}

function setSetting(setting, value) {
    var db = getDatabase();
    var ret = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value]);
        if (rs.rowsAffected > 0) {
            ret = "OK";
        } else {
            ret = "Error";
        }
    }
    );

    return ret;
}

function printSettings() {
    var db = getDatabase();
    db.transaction( function(tx) {
        var rs = tx.executeSql("SELECT * FROM settings;");
        for(var i = 0; i < rs.rows.length; i++) {
            var dbItem = rs.rows.item(i);
            console.log("Setting: " + dbItem.setting + ", Value: " + dbItem.value);
        }
    });
}

// function addWorkoutElement(title, type, duration, description) {
//     var db = getDatabase();
// }

function createWorkout(title){
    var db = getDatabase();

    var wid = _getFreeWid();

    // add new workout to table of contents 
    db.transaction(
    		   function(tx) {
    		       var query="INSERT OR REPLACE INTO toc VALUES(" + wid + ", '" + title + "');";
    		       tx.executeSql(query);
    		   });

    db.transaction(
                function(tx) {
                    var query="CREATE TABLE IF NOT EXISTS workout_" + wid + "(wid INTEGER, iid INTEGER, title TEXT, type TEXT, duration INTEGER, description TEXT);";
                    tx.executeSql(query);
                });
}

function deleteWorkout(widToRemove){
    var db = getDatabase();
    var ret = "";

    // remove workout from table of contents 
    db.transaction(
    		   function(tx) {
		       tx.executeSql('DELETE FROM toc WHERE wid=?;', [widToRemove]);
    		   });

    db.transaction(
                function(tx) {
                    var query="DROP TABLE IF EXISTS workout_" + widToRemove + ";";
                    tx.executeSql(query);
                });

    return ret;
}

function addExerciseToWorkout(wid, title, duration, description) {
    var db = getDatabase();
    var iid = _getNextIid(wid);

    db.transaction(
	function(tx) {
	    var query="INSERT INTO workout_" + wid 
		+ " VALUES(" 
		+ wid + ", " 
		+ iid + ", " 
		+ "'" + title + "', 'exercise', " 
		+ duration + ", " 
		+ "'" + description + "');";
	    tx.executeSql(query);
	});

    return {"iid": iid, "title": title, "type": "exercise", "duration": duration, "description": description};
}

function setExerciseInWorkout(wid, iid, title, description, duration) {
    var db = getDatabase();

    db.transaction(
	function(tx) {
	    tx.executeSql('UPDATE workout_' + wid + ' SET title =? WHERE iid =?;', [title, iid]);
	    tx.executeSql('UPDATE workout_' + wid + ' SET description =? WHERE iid =?;', [description, iid]);
	    tx.executeSql('UPDATE workout_' + wid + ' SET duration =? WHERE iid =?;', [duration, iid]);
	});

    return {"iid": iid, "title": title, "type": "exercise", "duration": duration, "description": description };
}

function addPauseToWorkout(wid, duration) {
    var db = getDatabase();
    var iid = _getNextIid(wid);

    db.transaction(
	function(tx) {
	    var query="INSERT INTO workout_" + wid + " VALUES(" + wid + ", " + iid + ", '', 'pause', " + duration + ", '');";
	    tx.executeSql(query);
	});

    return {"iid": iid, "title": "Pause", "type": "pause", "duration": duration, "description": "" };
}

function setPauseInWorkout(wid, iid, duration) {
    var db = getDatabase();

    db.transaction(
	function(tx) {
	    tx.executeSql('UPDATE workout_' + wid + ' SET duration =? WHERE iid =?;', [duration, iid]);
	});

    return {"iid": iid, "title": "Pause", "type": "pause", "duration": duration, "description": "" };
}

function deleteItemFromWorkout(wid, iidToRemove) {
    console.log("DELETE wid: " + wid + " iid: " + iidToRemove);
    var db = getDatabase();
    db.transaction(
	function(tx) {
	    tx.executeSql('DELETE FROM workout_' + wid + ' WHERE iid=?;', [iidToRemove]);
	});
}

function _getFreeWid() {
    var db = getDatabase();
    var wid = 1;
    var found = false;
    
    while(!found){
	db.transaction( function(tx) {
		var rs = tx.executeSql("SELECT * FROM toc WHERE wid =?;", [wid]);
		if(rs.rows.length === 0) {
		    console.log("Free WID found: " + wid);
		    found = true;
		}else{
		    wid += 1;
		}
	    });
    }
    
    return wid;
}

function _getNextIid(wid) {
    var db = getDatabase();
    var iid = -1;
    db.transaction(
    	function(tx) {
    	    var query="SELECT * FROM workout_" + wid + ";";
    	    var rs = tx.executeSql(query);
    	    iid = rs.rows.length;
    	});

    // db.transaction(
    // 	function(tx) {
    // 	    var query="SELECT count(*) FROM workout_" + wid + ";";
    // 	    var rs = tx.executeSql(query);
    // 	    iid = rs.rows.item(0).value;
    // 	    console.log("IIIIIIDDDDDDDDD: " + iid);
    // 	});

    // db.transaction( function(tx) {
    // 	var rs = tx.executeSql("SELECT * FROM workout_" + wid ";");
    // 	iid = rs.rows.length;
    // });

    return iid;
}

function createDummyWorkout(wid){
    var db = getDatabase();
    db.transaction(
    		   function(tx) {
    		       var query="DROP TABLE workout_" + wid + ";";
    		       tx.executeSql(query);
    		   });

    db.transaction(
                function(tx) {
                    var query="CREATE TABLE IF NOT EXISTS workout_" + wid + "(wid INTEGER, iid INTEGER, title TEXT, type TEXT, duration INTEGER, description TEXT);";
                    tx.executeSql(query);
                });

    db.transaction(
		   function(tx) {
		       var query="INSERT OR REPLACE INTO workout_" + wid + " VALUES(" + wid + ", 0, 'Liegestütz', 'excercise', 30, 'sdfsdf');";
		       tx.executeSql(query);
		   });
    db.transaction(
		   function(tx) {
		       var query="INSERT OR REPLACE INTO workout_" + wid + " VALUES(" + wid + ", 1, '', 'pause', 20, '');";
		       tx.executeSql(query);
		   });
    db.transaction(
		   function(tx) {
		       var query="INSERT OR REPLACE INTO workout_" + wid + " VALUES(" + wid + ", 2, 'Sit-Ups', 'excercise', 30, 'sdfsdf');";
		       tx.executeSql(query);
		   });
    db.transaction(
		   function(tx) {
		       var query="INSERT OR REPLACE INTO workout_" + wid + " VALUES(" + wid + ", 3, '', 'pause', 20, '');";
		       tx.executeSql(query);
		   });
}
