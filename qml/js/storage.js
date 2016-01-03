.import QtQuick.LocalStorage 2.0 as Sql

function getDatabase() {
    return Sql.LocalStorage.openDatabaseSync("SchwarzenmakerDb", "1.0", "Schwarzenmaker Workout Database", 1000000);
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
		       var query="INSERT INTO settings VALUES('AudibleTimerVolume', '0.5');";
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
		       var query="INSERT INTO settings VALUES('DefaultExcerciseDuration', '40');";
		       tx.executeSql(query);
		   });

    db.transaction(
		   function(tx) {
		       var query="INSERT INTO settings VALUES('Orientation', '0');";
		       tx.executeSql(query);
		   });

    db.transaction(
		   function(tx) {
		       var query="INSERT INTO settings VALUES('OverlayOpacity', '0.7');";
		       tx.executeSql(query);
		   });

    db.transaction(
		   function(tx) {
		       var query="INSERT INTO settings VALUES('OverlayProgressBarThickness', '5');";
		       tx.executeSql(query);
		   });

    ////////////////////////////////
    // create table of contents
    ////////////////////////////////
    initTocTable();
}

function initTocTable() {
    var db = getDatabase();
    db.transaction(
		   function(tx) {
		       var query="CREATE TABLE IF NOT EXISTS toc(wid INTEGER UNIQUE PRIMARY KEY ON CONFLICT IGNORE, wtitle TEXT);";
		       tx.executeSql(query);
		   });
}

function clearWorkoutDatabase(){
    var db = getDatabase();

    db.transaction(function(tx) {
     	var rs = tx.executeSql("SELECT wid FROM toc;")
	for(var i = 0; i < rs.rows.length; i++){
	    console.log("DROP WORKOUT TABLE ", getWorkoutTableNameFromId(rs.rows.item(i).wid) )
	    tx.executeSql("DROP TABLE IF EXISTS " + getWorkoutTableNameFromId(rs.rows.item(i).wid + ";"))
	}
    })

    db.transaction(function(tx) {
	console.log("DROP TOC TABLE")
     	tx.executeSql("DROP TABLE IF EXISTS toc")
    })
    initTocTable()
}

function printWorkout(wid) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT * FROM " + getWorkoutTableNameFromId(wid) + ";");
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

    console.log("Get Setting ", setting, " --> ", ret)
    
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

    console.log("Set Setting ", setting, "::", value, " --> ", ret)
    
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

function createWorkout(wid){
    var db = getDatabase();

    if(wid === -1){
	wid = _getFreeWid();
    }
    
    // create table for workout contents
    db.transaction(
                function(tx) {
                    // var query="CREATE TABLE IF NOT EXISTS workout_" + wid + "(iid INTEGER UNIQUE PRIMARY KEY ON CONFLICT IGNORE, wid INTEGER, title TEXT, type TEXT, duration INTEGER, description TEXT);";
                    var query="CREATE TABLE IF NOT EXISTS " + getWorkoutTableNameFromId(wid) + "(iid INTEGER, wid INTEGER, title TEXT, type TEXT, duration INTEGER, description TEXT);";

		    console.log("createWorkout SQL  statement: ", query)
                    tx.executeSql(query);
                });

    return wid;
}

function setWorkoutTitle(wid, title){
    var db = getDatabase();

    console.log("setWorkoutTitle: ", wid, " ", title)
    
    db.transaction(
	function(tx) {
    	    var query="INSERT OR REPLACE INTO toc VALUES(" + wid + ", '" + title + "');";
    	    tx.executeSql(query);
    	}
    );
}

function swapItemId(workoutId, firstItemId, secondItemId){
    var db = getDatabase();
    var firstItem;
    var secondItem;
    var workoutName = getWorkoutTableNameFromId(workoutId);

    db.transaction(function(tx) {
	firstItem = tx.executeSql("SELECT * FROM " + workoutName + " WHERE iid = ?;", [firstItemId]);   
	secondItem = tx.executeSql("SELECT * FROM " + workoutName + " WHERE iid = ?;", [secondItemId]); });

    if( (firstItem.rows.length != 0) && (secondItem.rows.length != 0) ){
	db.transaction(function(tx) {
	    tx.executeSql("UPDATE " + workoutName + " SET iid=-1 WHERE iid=?;", [secondItemId])
	    tx.executeSql("UPDATE " + workoutName + " SET iid=? WHERE iid=?;", [secondItemId, firstItemId])
	    tx.executeSql("UPDATE " + workoutName + " SET iid=? WHERE iid=?;", [firstItemId, -1])
	})
    }
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
    var iid = _getFreeIid(wid);

    db.transaction(
	function(tx) {
	    var query="INSERT INTO " + getWorkoutTableNameFromId(wid)
		+ " VALUES(" 
		+ iid + ", " 
		+ wid + ", " 
		+ "'" + title + "', 'exercise', " 
		+ duration + ", " 
		+ "'" + description + "');";
	    console.log("addExerciseToWorkout SQL query: ", query)
	    tx.executeSql(query);
	});

    return {"iid": iid, "title": title, "type": "exercise", "duration": duration, "description": description};
}

function setExerciseInWorkout(iid, wid, title, description, duration) {
    var db = getDatabase();

    db.transaction(
	function(tx) {
	    tx.executeSql('UPDATE ' + getWorkoutTableNameFromId(wid) + ' SET title =? WHERE iid =?;', [title, iid]);
	    tx.executeSql('UPDATE ' + getWorkoutTableNameFromId(wid) + ' SET description =? WHERE iid =?;', [description, iid]);
	    tx.executeSql('UPDATE ' + getWorkoutTableNameFromId(wid) + ' SET duration =? WHERE iid =?;', [duration, iid]);
	});

    return {"iid": iid, "title": title, "type": "exercise", "duration": duration, "description": description };
}

function addPauseToWorkout(wid, duration) {
    var db = getDatabase();
    var iid = _getFreeIid(wid);

    db.transaction(
	function(tx) {
	    var query="INSERT INTO workout_" + wid + " VALUES(" + iid + ", " + wid + ", '', 'pause', " + duration + ", '');";
	    console.log("addPauseToWorkout SQL query: ", query)
	    tx.executeSql(query);
	});

    return {"iid": iid, "title": "Pause", "type": "pause", "duration": duration, "description": "" };
}

function setPauseInWorkout(wid, iid, duration) {
    var db = getDatabase();

    db.transaction(
	function(tx) {
	    tx.executeSql('UPDATE ' + getWorkoutTableNameFromId(wid) + ' SET duration =? WHERE iid =?;', [duration, iid]);
	});

    return {"iid": iid, "title": "Pause", "type": "pause", "duration": duration, "description": "" };
}

function deleteItemFromWorkout(wid, iidToRemove) {
    console.log("DELETE wid: " + wid + " iid: " + iidToRemove);
    var db = getDatabase();
    db.transaction(
	function(tx) {
	    tx.executeSql('DELETE FROM ' + getWorkoutTableNameFromId(wid) + ' WHERE iid=?;', [iidToRemove]);
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

function _getFreeIid(wid) {
    var db = getDatabase();
    var iid = 0;

    db.transaction(
    	function(tx) {
    	    var rs = tx.executeSql("SELECT MAX(iid) AS maxIid FROM " + getWorkoutTableNameFromId(wid) + ";");
    	    iid = rs.rows.item(0).maxIid + 1;
    	}
    );
    
    return iid;
}

function getWorkoutTableNameFromId(workoutId){
    return "workout_" + workoutId;
}
