use Study

// Count number of documents with "Math" subject 
db.TestShedule.aggregate([
    {  
        $match:{
            Subject: "Math"
        }
    }, 
    {
        $group:{
            _id: null, 
            total: {
                $sum : 1
            }
        }
    }
])


// Count number of pass exams for each listner 
db.TestShedule.aggregate([
  {
    $match: {
      PassDate: {
        $ne: null
      }
    }
  },
  {
    $group:{
      _id: "$ListnerId",
      passed_exams_count: {
        $sum: 1
      }
    }
  }
])


// Select newest test date for Listners
db.Listeners.aggregate(
  {
    $group: {
      _id: null,
      newest_pass_date: {
        $max: "$LastTestDate"
      }
    }
  }
)


// Select easiest subject
db.TestShedule.aggregate([
  {
    $match: {
      PassDate: {
        $ne: null
      }
    }
  }, 
  {
    $group: {
      _id: "$Subject",
      listner_pass_count: {
        $sum : 1
      }
    }
  }, 
  {
    $sort: {
      listner_pass_count: -1
    }
  }, 
  {
    $limit: 1
  }
])


// JOIN
// Output all listeners that took Math exam
db.TestShedule.aggregate([
  {
    $match: {
      Subject: "Math"
    }
  }, 
  {
    $lookup: {
      from: "Listeners",
      localField: "ListnerId",
      foreignField: "ListenerId",
      as: "Listener"
    }
  },
  {
    $unwind: "$Listener"
  }
])


// ALT JOIN
var mapData = function () {
  var output= {
    Id: this.ListenerId,
    Subject: this.Subject,
    FirstName: null,
    LastName: null
  };
  
  emit(this.ListnerId, output);
};

var mapListner = function () {
  var output= {
    Id: this.ListenerId,
    FirstName: this.FirstName, 
    LastName: this.LastName,
    Subject: null
  };
  
  emit(this.ListenerId, output);
};

var reduceF = function(key, values) {
  var result = { 
    Subject: [], 
    FirstName: null,
    LastName: null
  };
  
  values.forEach(function(value) {
    if(result.FirstName == null) {
      result.FirstName = value.FirstName;
    }
    if(result.LastName == null) {
      result.LastName = value.LastName;
    }
    if(value.Subject != null) {
      result.Subject = result.Subject.concat([value.Subject]);
    }
  });
  
  return result;
};

result = db.Listeners.mapReduce(
  mapListner, 
  reduceF, 
  {out: 
    {reduce: 'joined_collection'}
  }
);

result = db.TestShedule.mapReduce(
  mapData, 
  reduceF, 
  {out: 
    {reduce: 'joined_collection'}
  }
);

db.joined_collection.find()

