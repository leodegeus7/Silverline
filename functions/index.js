const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();


exports.getCustomer = functions.https.onRequest((request, response) => {
	var db = admin.firestore();
	console.log("cool1");
	var attendant = request.query.attendant;
	if (attendant == null) {
		response.send('Any attendant founded!');
    }

    db.collection('attendants').doc(attendant).get()
		.then(doc2 => {
		  if(doc2.exists){
		  	var attendantAreas = doc2.data().areas;
		     db.collection('customers').orderBy("datetime").get().then(function(querySnapshot) {
				if (querySnapshot.size == 0) {
					response.send("No customers");
				} else {
					var foundedIt = false;
					querySnapshot.forEach(doc => {
						var data = doc.data();
						var id = doc.id;
				    	if (data != null) {
				    		if ((attendantAreas.indexOf(data.area) > -1) && !foundedIt) {
				    			foundedIt = true;
								var object = {};
								object.attendant = doc2.data().name;
								object.customer = data.name;
								object.area = data.area;
								object.date = Date();
								db.collection("customers").doc(id).delete();
								db.collection("perfomed").add(object);
								db.collection("status").doc("info").get().then(function(snapshot) {
									var info = snapshot.data();
									if (info != null) {
										var count = info.document_count;
										var object = {};
										object.document_count = count - 1;
										db.collection("status").doc("info").set(object, { merge: true });
										response.send(data);
									}
								});
							}
						} else {
							response.send("Error to find date " + fromDate + " in database");
						}	
			    	});
			    	if (foundedIt == false) {
			    		response.send("Didn't find any customer with attendant area function");
			    	}
				}

			});
		  } else {
		  		response.send("Error to find attendant " + attendant);
		  }
		});


	
});

exports.getCustomerWithId = functions.https.onRequest((request, response) => {
	var db = admin.firestore();
	console.log("cool1");
	var attendant = request.query.attendant;
	if (attendant == null) {
		response.send('Any attendant founded!');
    }

    var customerId = request.query.customerId;
	if (customerId == null) {
		response.send('Any customerId founded!');
    }

    db.collection('customers').doc(customerId).get().then(function(querySnapshot) {
		var customer = querySnapshot.data();
		if (customer != null) {
			var object = {};
			object.attendant = attendant;
			object.customer = customer.name;
			object.area = customer.area;
			object.date = Date();
			db.collection("customers").doc(customerId).delete();
			db.collection("perfomed").add(object);
			db.collection("status").doc("info").get().then(function(snapshot) {
				var info = snapshot.data();
				if (info != null) {
					var count = info.document_count;
					var object = {};
					object.document_count = count - 1;
					db.collection("status").doc("info").set(object, { merge: true });
					response.send("Perfomed");
				}
			});
		} else {
			response.send("Didn't find any customer with this id");
		}
	});
});

exports.addCustomer = functions.https.onRequest((request, response) => {
	var db = admin.firestore();
	var name = request.query.name;
	if (name == null) {
		response.send('Any name founded!');
    }
    var area = request.query.area;
	if (area == null) {
		response.send('Any area founded!');
    }
    var object = {};
	object.name = name;
	object.area = area;
	object.datetime = new Date();
    db.collection('customers').doc().set(object, { merge: true });

	db.collection("status").doc("info").get().then(function(snapshot) {
		var info = snapshot.data();
		if (info != null) {
			var count = info.document_count;
			var object = {};
			object.document_count = count + 1;
			db.collection("status").doc("info").set(object, { merge: true });
			response.send("Customer Ok");
		}  else {
			var object = {};
			object.document_count = 1;
			db.collection("status").doc("info").set(object, { merge: true });
			response.send("Customer Ok");
		}
	});
});
