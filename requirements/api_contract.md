//start master table

//login 
 {
   "email" : "test@user.com",
   "password" : "test@123"
 }

 //forget password 
 {
   "email" : "test@user.com"
 }

 //reset password 
 {
   "token" : "fnejrje2323bujbf",
   "password": "test@123"
   "confomr_password": "test@123"
 }

// create and update user
 {
    "first_name" :"test",
    "last_name" :"test",
    "gender" : "male",
    "date_of_birth" : "30-08-1999",
    "email": "test@user.com",
    "mobile" : 1234567890,
    "password": "test@123",
    "is_active": true,
    "team_id" : 1,
    "level_id" : 2
 }


 //list of users 
 [
   {
      "id" : 123,
      "first_name" :"test",
      "last_name" :"test",
      "gender" : "male",
      "date_of_birth" : "30-08-1999",
      "email": "test@user.com",
      "mobile" : 1234567890,
      "is_active": true,
      "created_at" : "2026-11-02T09:17:24",
      "updated_at" : "2026-11-02T09:17:24"
      "team" :{
        "id" : 1
        "name" : "test one"
      },
      "level" : {
        "id" : 1
        "name" : "test one"
      }
   }
 ]


/// master tables 

//create and update teams 
{
  "name" : "test team"
  "is_active" : true
}

//list teams 
[
  {
      "id" : 1
      "name" : "test team"
      "is_active" : true,
      "created_at" : "2026-11-02T09:17:24",
      "updated_at" : "2026-11-02T09:17:24"
    }
]

//create and update levels 
{
  "name" : "test level",
  "team_id" : 1 
  "is_active" : true
}

//list teams 
[
  {
      "id" : 1
      "name" : "test level"
      "is_active" : true,
      "team" : {
      "id" : 1,
      "name" : "test team"
      }
      "created_at" : "2026-11-02T09:17:24",
      "updated_at" : "2026-11-02T09:17:24"
    }
]


//create and update address_type 
{
  "name" : "test address_type"
  "is_active" : true
}

//list address type  
[
  {
      "id" : 1
      "name" : "test address_type"
      "is_active" : true,
      "created_at" : "2026-11-02T09:17:24",
      "updated_at" : "2026-11-02T09:17:24"
    }
]

//create and update country 
{
  "name" : "test country"
  "is_active" : true
}

//list country  
[
  {
      "id" : 1
      "name" : "test country"
      "is_active" : true,
      "created_at" : "2026-11-02T09:17:24",
      "updated_at" : "2026-11-02T09:17:24"
    }
]

//create and update contact type 
{
  "name" : "test contact type"
  "is_active" : true
}

//list contact type  
[
  {
      "id" : 1
      "name" : "test contact type"
      "is_active" : true,
      "created_at" : "2026-11-02T09:17:24",
      "updated_at" : "2026-11-02T09:17:24"
    }
]


//create and update state 
{
  "name" : "test state"
  "country_id" :12
  "is_active" : true
}

//list state  
[
  {
      "id" : 1
      "name" : "test state",
      "country":{
      "id" :1,
      "name" "test country"
      }
      "is_active" : true,
      "created_at" : "2026-11-02T09:17:24",
      "updated_at" : "2026-11-02T09:17:24"
    }
]

//create and update district 
{
  "name" : "test district"
  "state_id" :12
  "is_active" : true
}

//list district  
[
  {
      "id" : 1
      "name" : "test district",
      "state":{
      "id" :1,
      "name" "test state"
      }
      "is_active" : true,
      "created_at" : "2026-11-02T09:17:24",
      "updated_at" : "2026-11-02T09:17:24"
    }
]

//create and update taluka 
{
  "name" : "test taluka"
  "district_id" :12
  "is_active" : true
}

//list taluka  
[
  {
      "id" : 1
      "name" : "test taluka",
      "district":{
      "id" :1,
      "name" "test district"
      }
      "is_active" : true,
      "created_at" : "2026-11-02T09:17:24",
      "updated_at" : "2026-11-02T09:17:24"
    }
]


//create and update verification status 
{
   "title" : "test title",
   "description" : "test description",
   "type": "test type",
   "show_on_report" : "test verification title"
   "is_active" : true
}

//list of verification 
[
  {
  "id" :1
   "title" : "test title",
   "description" : "test description",
   "type": "test type",
   "show_on_report" : "test verification title"
   "is_active" : true,
    "created_at" : "2026-11-02T09:17:24",
      "updated_at" : "2026-11-02T09:17:24"
}
]

////end of master tables

//create and update address 
{
  "address_type_id" : "1",
  "line_one": "bcjd cekn",
  "line_two": "bcjd cekn",
  "pin_code": "1234456",
  "is_active: true
  "country_id" : 1,
  "state_id" : 1,
  "district_id" : 1,
  "taluka_id" : 1,
}

//list of address 
[
{
  "address_type_id" : "1",
  "line_one": "bcjd cekn",
  "line_two": "bcjd cekn",
  "pin_code": "1234456",
  "is_active: true
  "country" : {
  "id" : 1,
  "name" : "test"
  },
  "state" : {
  "id" : 1,
  "name" : "test"
  },
  "district" : {
  "id" : 1,
  "name" : "test"
  },
  "taluka" : {
  "id" : 1,
  "name" : "test"
  },
  "created_at" : "2026-11-02T09:17:24",
      "updated_at" : "2026-11-02T09:17:24"
}
]


//create and update company
{
  "name" : "tst ",
  "offical_name":"offical company name",
  "website": "www.test.com";
  "is_active": true,
  "registered_address" : {
  "address_type_id" : "1",
  "line_one": "bcjd cekn",
  "line_two": "bcjd cekn",
  "pin_code": "1234456",
  "is_active: true
  "country_id" : 1,
  "state_id" : 1,
  "district_id" : 1,
  "taluka_id" : 1,
},
  "corporate_address" : {
  "address_type_id" : "1",
  "line_one": "bcjd cekn",
  "line_two": "bcjd cekn",
  "pin_code": "1234456",
  "is_active: true
  "country_id" : 1,
  "state_id" : 1,
  "district_id" : 1,
  "taluka_id" : 1,
}
}

// list of company 
[
  {
    "name" : "tst ",
    "offical_name":"offical company name",
    "website": "www.test.com";
    "is_active": true,
    "created_at" : "2026-11-02T09:17:24",
    "updated_at" : "2026-11-02T09:17:24"
  }
]

// show company 
{
  "name" : "tst ",
  "offical_name":"offical company name",
  "website": "www.test.com";
  "is_active": true,
  "registered_address" : {
  "address_type" : {
  "id" : 1,
  "name" : "test"
  },
  "line_one": "bcjd cekn",
  "line_two": "bcjd cekn",
  "pin_code": "1234456",
  "is_active: true
  "country" : {
  "id" : 1,
  "name" : "test"
  },
  "state" : {
  "id" : 1,
  "name" : "test"
  },
  "district" : {
  "id" : 1,
  "name" : "test"
  },
  "taluka" : {
  "id" : 1,
  "name" : "test"
  },
},
  "corporate_address" : {
  "address_type_id" : "1",
  "line_one": "bcjd cekn",
  "line_two": "bcjd cekn",
  "pin_code": "1234456",
  "is_active: true
 "country" : {
  "id" : 1,
  "name" : "test"
  },
  "state" : {
  "id" : 1,
  "name" : "test"
  },
  "district" : {
  "id" : 1,
  "name" : "test"
  },
  "taluka" : {
  "id" : 1,
  "name" : "test"
  },
}
}


//create and update lots 
{
  "name" :"losts"
  "is_active" : true,
  "company_id": 1
}

//list of lost 
[
{
  "id" : 1
  "name" :"losts"
  "is_active" : true,
  "company": {
  "id" : 1,
  "name" : "Company name "
  },
      "created_at" : "2026-11-02T09:17:24",
    "updated_at" : "2026-11-02T09:17:24"
}
]

// create and update contacts 
{
  "name" : "test name", 
  "email" : "test@user.com",
  "company_id": 1,
  "contact_type_id": 1
  "is_helpfull": true,
  "is_active" : true
}

//list of contacts
[
  {
  "id" : 12,
  "name" : "test name", 
  "email" : "test@user.com",
  "company": {
    "id" : 1,
    "name" : "company",
  },
  "contact_type_id": {
    "id" : 1,
    "name" : "company",
  },
  "is_helpfull": true,
  "is_active" : true,
   "created_at" : "2026-11-02T09:17:24",
    "updated_at" : "2026-11-02T09:17:24"
}
]


//create and update employees 
{
"first_name" :"test",
    "last_name" :"test",
    "gender" : "male",
    "date_of_birth" : "30-08-1999",
    "email": "test@user.com",
    "mobile" : 1234567890,
    "password": "test@123",
    "is_active": true,
    "company_id: 1
    "lot_id": 1
}

//list of employees 
[
{
"id":1,
"first_name" :"test",
    "last_name" :"test",
    "gender" : "male",
    "date_of_birth" : "30-08-1999",
    "email": "test@user.com",
    "mobile" : 1234567890,
    "password": "test@123",
    "is_active": true,
    "company_id: {
     "id" : 1,
     "name" : "test"
    },
    "lot_id": {
     "id" : 1,
     "name" : "test"
    },
    "created_at" : "2026-11-02T09:17:24",
    "updated_at" : "2026-11-02T09:17:24"
}
]


// for each verification 
create and update 
{
   "verification_status_id":1,
   "employee_id": 1,
   "clinet_review": "vnsjbnkjcvkbwk",
    "initiated_at:  "2026-11-02T09:17:24"
}

list 
[
  {
  "id" : 1
   "verification_status": {
     "id" :1,
     "name": "test"
   },
   "employee_id": {
     "id" :1,
     "name": "test"
   },
   "clinet_review": "vnsjbnkjcvkbwk",
    "initiated_at:  "2026-11-02T09:17:24"
}
]
