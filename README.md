# ZSSN (Zombie Survival Social Network)

## Problem Description

The world as we know it has fallen into an apocalyptic scenario. A laboratory-made virus is transforming human beings and animals into zombies, hungry for fresh flesh.

You, as a zombie resistance member (and the last survivor who knows how to code), was designated to develop a system to share resources between non-infected humans.

## Table of Contents

* [Installation](#installation)
* [Live Version](#live-version)
* [API Documentation](#api-documentation)
  * [List Survivors](#list-survivors)
  * [Add Survivors](#add-survivors)
  * [Update Survivor Location](#update-survivor-location)
  * [Report Survivor as Infected](#report-survivor-as-infected)
  * [Trade Resources](#trade-resources)
* [Reports](#reports)
  * [Percentage of infected survivors](#percentage-of-infected-survivors)
  * [Percentage of non-infected survivors](#percentage-of-non-infected-survivors)
  * [Average Resources By Survivor](#average-resources-by-survivor)
  * [Points lost because of infected survivors](#points-lost-because-of-infected-survivors)
* [Testing with RSpec](#testing-with-rspec)
* [Credits](#credits)

## Installation

**Dependention note**: Before installation make sure to have sqlite3 (3.24) and Ruby (2.6.2) installed and up. 

1. Clone the project.

	~~~ sh
	$ git clone https://github.com/robertoeb/zssn-api.git
	~~~

2. Bundle the Gems.

	~~~ sh
	$ bundle install
	~~~

3. Create and migrate the database.

    ~~~ sh
    $ rails db:create
    $ rails db:migrate
    ~~~

4. Start the application

	~~~ sh
	$ rails s
	~~~

Application will be runing at [localhost:3000](http://localhost:3000).

## Live Version
You can test a live version of the API using a URL [http://zssn.ml:3000](http://zssn.ml:3000/survivors)

## API Documentation

### List Survivors

##### Request 

```sh
GET  /survivors`
```

##### Response

```sh
status: 200 Ok
```

```sh
Content-Type: "application/json"
```

```sh
{
    "survivors": [
        {
            "id": 1,
            "name": "Rick Grimes",
            "age": 38,
            "gender": "M",
            "latitude": -84.3879824,
            "longitude": -84.3879824,
            "infection_mark": 0
        },
        {
            "id": 2,
            "name": "Carl Grimes",
            "age": 14,
            "gender": "M",
            "latitude": -84.3879824,
            "longitude": -84.3879824,
            "infection_mark": 0
        }
    ]
}
```

### Add Survivors

##### Request 

```sh
POST  /survivors`
```

```sh
Parameters:
{
    "survivor": 
    {
        "name": "Glenn Rhee", 
        "age": "27", 
        "gender": "M", 
        "latitude": "-84.3879824", 
        "longitude": "-84.3879824",
        "resources": [
        {
            "item": "Water", 
            "amount": 10
            
        }, 
        { 
            "item":"Ammunition", 
            "amount": 60
            
        },
        { 
            "item":"Food", 
            "amount": 30
            
        },
        { 
            "item":"Medication", 
            "amount": 20
            
        }
        ]
    }
}
```

##### Response

```sh
status: 201 created
```

```sh
Content-Type: "application/json"
```

```sh
{
    "survivor": {
        "id": 3,
        "name": "Glenn Rhee",
        "age": 27,
        "gender": "M",
        "latitude": -84.3879824,
        "longitude": -84.3879824,
        "infection_mark": 0
    }
}
```

##### Errors
Status | Error                | Message
------ | ---------------------|--------
422    | Unprocessable Entity |   
409    | Conflict             | Survivors need to declare their resources

### Update Survivor Location

##### Request 

```sh
PATCH/PUT /survivors/:id
```

```sh
Parameters:
{
    "survivor": 
    {
        "latitude": "33.7490", 
        "longitude": "84.3880"
    }
}
```

##### Response

```sh
status: 200 Ok
```

```sh
Content-Type: "application/json"
```

```sh
{
    "id": 3,
    "latitude": 33.749,
    "longitude": 84.388,
    "name": "Glenn Rhee",
    "age": 27,
    "gender": "M",
    "infection_mark": 0
}
```

##### Errors
Status | Error    					| Message
------ | ---------------------------|----------
404    | Not Found         			|
422    | Unprocessable Entity       |

### Report Survivor as Infected

##### Request 

```sh
POST   /survivors/:id/report_infection
```

##### Response

```sh
status: 200 ok
```

```sh
Content-Type: "application/json"
```

```sh
{
    "message": "Survivor reported as infected 1 times"
    "message": "He's a walker, do him a favor, shoot his head."
}
```

##### Errors
Status | Error      | Message
------ | -----------|--------
404    | Not Found  | Couldn't find Survivor with 'id'=:id


### Trade Resources

Survivors can trade items among themselves, respecting a points table.

##### Request 

```sh
POST   /trade
```

```sh
{
  "trade": {
    "survivor1": {
      "id": "1",
      "resources": [
        {
          "item": "Water",
          "amount": 1
        }
      ]
    },
    "survivor2": {
      "id": "2",
      "resources": [
        {
          "item": "Ammunition",
          "amount": 4
        }
      ]
    }
  }
}
```

##### Response

```sh
status: 200 ok
```

```sh
Content-Type: "application/json"
```

```sh
Body:
{
    "message": "Trade successfully completed"
}
```

##### Errors
Status | Error                | Message
------ | ---------------------|--------
404    | Not Found            | Couldn't find Survivor with 'id'=X
409    | Conflict             | SurvivorX It's infected! Run away or kill him!
409    | Conflict             | Invalid resources for SurvivorX
409    | Conflict             | Resources points is not balanced both sides


## Reports

### Percentage of infected survivors

##### Request 

```sh
GET   /reports/infected_survivors
```

##### Response

```sh
status: 200 ok
```

```sh
Content-Type: "application/json"
```

```sh
{
    "percentage": "100%"
}
```

### Percentage of non-infected survivors

##### Request 

```sh
GET   /reports/uninfected_survivors
```

##### Response

```sh
status: 200 ok
```

```sh
Content-Type: "application/json"
```

```sh
Body:
{
    "percentage": "0%"
}
```

### Average Resources By Survivor

##### Request 

```sh
GET   /reports/resources_by_survivor
```

##### Response

```sh
status: 200 ok
```

```sh
Content-Type: "application/json"
```

```sh
{
    "averages": {
        "water": 10,
        "food": 30,
        "medication": 20,
        "ammunition": 60
    }
}
```

### Points lost because of infected survivors

##### Request 

```sh
GET   /reports/lost_infected_points
```

##### Response

```sh
status: 200 ok
```

```sh
Content-Type: "application/json"
```

```sh
Body:
{
    "lost_points": 0
}
```

## Testing with RSpec

To execute the tests just run the tests with RSpec.

1. Execute all tests

    ~~~ sh
    $ rails -s
    ~~~

## Credits

- [Roberto E. B. Junior](https://www.linkedin.com/in/robertoeb/) - **I'M NEGAN**
