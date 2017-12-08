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
