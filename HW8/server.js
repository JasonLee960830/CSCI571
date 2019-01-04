//express_demo.js 文件
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var multer = require('multer'); 
var request = require('request');
var geohash = require('ngeohash');
var SpotifyWebApi = require('spotify-web-api-node');

// credentials are optional
var spotifyApi = new SpotifyWebApi({
  clientId: '24b7c17d79524145b6ee3e9badc5387a',
  clientSecret: '5362d2839c5f47a88c8fceeaf6e485c5',
  redirectUri: 'http://www.example.com/callback'
});
//upload static file
app.use(express.static('public'));

app.use(bodyParser.json()); // for parsing application/json
app.use(bodyParser.urlencoded({ extended: true })); // for parsing application/x-www-form-urlencoded
//app.use(multer()); // for parsing multipart/form-data

app.all('*', function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Content-Type,Content-Length, Authorization, Accept,X-Requested-With");
    res.header("Access-Control-Allow-Methods","PUT,POST,GET,DELETE,OPTIONS");
    res.header("X-Powered-By",' 3.2.1')
    if(req.method=="OPTIONS") res.send(200);/*让options请求快速返回*/
    else  next();
}); 

// app.post('/geocoding',function (req,res){
// 	var googleKey = "AIzaSyC7tqbcASHS3luuZS5D3rH0sR6owqPtofU";
// 	var url = "https://maps.googleapis.com/maps/api/geocode/json?address="+req.body.specifiedLocation+"&key="+googleKey;
// 	request(url,function(error,response,body){
// 		if (!error && response.statusCode == 200) {
// 			res.
// 		}
// 	})
// })

app.get('/search', function (req, res) {
	var segmentId ="";
	var geoPoint = "";
	console.log("currentLat",req.query.currentLat);
	console.log("currentLon",req.query.currentLon);
	console.log("location",req.query.formLocation)
	// switch (req.body.form.category)
	switch(req.query.formCategory)
    {
        case 'Music':
            segmentId = "KZFzniwnSyZfZ7v7nJ";
            break;
        case 'Sports':
            segmentId = "KZFzniwnSyZfZ7v7nE";
            break;
        case 'Arts&Theatre':
            segmentId = "KZFzniwnSyZfZ7v7na";
            break;
        case 'Theatre':
            segmentId = "KZFzniwnSyZfZ7v7na";
            break;
        case 'Film':
            segmentId = "KZFzniwnSyZfZ7v7nn";
            break;
        case 'Miscellaneous':
            segmentId ="KZFzniwnSyZfZ7v7n1";
            break;
        default:
            segmentId = "";
    }
    //console.log(segmentId);
	if(req.query.formLocation=="otherLocation"){
		var url = "https://maps.googleapis.com/maps/api/geocode/json?address="+req.query.formSpecifiedLocation+"&key=AIzaSyC7tqbcASHS3luuZS5D3rH0sR6owqPtofU";
		request(url, function (error, response, body) {
	  		if (!error && response.statusCode == 200) {
	  			var data = JSON.parse(body);
	   			var lng = data.results[0].geometry.location.lng;
	   			var lat = data.results[0].geometry.location.lat;
	   		    geoPoint = geohash.encode(lat, lng)
				//var latlon = geohash.decode('ww8p1r4t8');
	  		}
		})
	}
	else if(req.query.formLocation=="currentLocation"){
		console.log("calculate");
		geoPoint = geohash.encode(req.query.currentLat,req.query.currentLon);
	}
	console.log("geoPoint",geoPoint);
	var eventUrl = "https://app.ticketmaster.com/discovery/v2/events.json?apikey=PVim49x71n5y9vPEDQNBrAfBFnGAkKnm&keyword="+req.query.formKeyword+"&segmentId="+segmentId+"&radius="+req.query.formDistance+"&unit="+req.query.formUnit+"&geoPoint="+geoPoint;
	var event = "";
	console.log("eventUrl",eventUrl);
	request(eventUrl,function(error,response,body){
		if(!error && response.statusCode ==200){
			console.log("no error");
			//console.log(body);
			res.send(body);
		}
	})
  	//res.send(event);
})

app.get('/showDetails', function (req, res){
	var eventDetailUrl = "https://app.ticketmaster.com/discovery/v2/events/"+req.query.eventId+".json?apikey=PVim49x71n5y9vPEDQNBrAfBFnGAkKnm";
	//console.log(eventDetailUrl);
	request(eventDetailUrl,function(error,response,body){
		if(!error&& response.statusCode ==200){
			//console.log(body);
			res.send(body)
		}
	})
})

app.get('/showArtistInfo1',function (req,res){
	// Retrieve an access token.
	spotifyApi.clientCredentialsGrant().then(
	  function(data) {
	    //console.log('The access token expires in ' + data.body['expires_in']);
	    //console.log('The access token is ' + data.body['access_token']);

	    // Save the access token so that it's used in future calls
	    spotifyApi.setAccessToken(data.body['access_token']);
	    //console.log(req.body.artistName);
		// Search artists whose name contains artistnName
		spotifyApi.searchArtists(req.query.artistName)
		  .then(function(data) {
		  	console.log("section 1");
		  	//console.log(req.body.artistName);
		  	//console.log(data.body);
		    //console.log('Search artists by ',req.body.artistName[0].name, data.body);
		    var targetData  ={};
		    var items = data.body.artists.items;
		    if(items!=""){
			    var itemLength = items.length;
			    for(var i = 0;i<itemLength;i++){
			    	if(req.query.artistName.toLowerCase()==items[i].name.toLowerCase()){
			    		targetData.name = items[i].name;
			    		targetData.followers = items[i].followers.total;
			    		targetData.popularity = items[i].popularity;
			    		targetData.checkAt = items[i].external_urls.spotify;
			    		res.send(targetData);
			    		//console.log("targetData:",targetData);
			    		break;
			    	}
			    }
			}
			else{
				console.log("there is nothing found");
				res.send(targetData);
			}
		    //console.log(itemLength);
		    //res.send(data.body);
		  }, function(err) {
		    console.error(err);
		  });
	  },
	  function(err) {
	    console.log('Something went wrong when retrieving an access token', err);
	  }
	);
})

app.get('/showArtistInfo2',function(req,res){
	var apiKey = "AIzaSyBqpeVLGZ981Z9zpIypYkeFoIfO8hdJnt8";
	var engineId = "016314606610102624077:4cy6yiejno8";
	var artistNames = req.query.artistNames;
	var responseData = {};
	//console.log("artistNames are: ", artistNames);
	//console.log("important!!!!",artistNames[0]);
	var artistInfo2Url = "https://www.googleapis.com/customsearch/v1?q="+artistNames+"&cx="+engineId+"&imgSize=huge&imgType=news&num=9&searchType=image&key="+apiKey;
	console.log(artistInfo2Url);
	request(artistInfo2Url,function(error,response,body){
		if(!error&& response.statusCode ==200){
			console.log("section 2");
			res.send(body);
		}
	})
	
})

app.get('/showVenueInfo',function(req,res){
	var apiKey = "PVim49x71n5y9vPEDQNBrAfBFnGAkKnm";
	var venueName = req.query.venueName;
	var venueInfoUrl = "https://app.ticketmaster.com/discovery/v2/venues?apikey="+apiKey+"&keyword="+venueName;
	request(venueInfoUrl,function(error,response,body){
		if(!error&&response.statusCode ==200){
			//console.log(body);
			res.send(body);
		}
	})
})
app.get('/geocode',function(req,res){
	var mapInfoUrl = "https://maps.googleapis.com/maps/api/geocode/json?address="+req.query.venueName+"&key=AIzaSyC7tqbcASHS3luuZS5D3rH0sR6owqPtofU";
	request(mapInfoUrl,function(error,response,body){
		if(!error&&response.statusCode == 200){
			var data = JSON.parse(body);
	   		var lng = data.results[0].geometry.location.lng;
	   		var lat = data.results[0].geometry.location.lat;
	   		var mapInfo={"lat":lat,"lng":lng};
			res.send(mapInfo);
		}
	})
})

app.get('/showUpcomingEvents',function(req,res){
	var songKickApiKey = "FP3fllp0HIwxFAzY";
	var venueName = req.query.venueName;
	var upcomingEventsUrl1 = "https://api.songkick.com/api/3.0/search/venues.json?query="+venueName+"&apikey="+songKickApiKey;
	request(upcomingEventsUrl1,function(error,response,body){
		if(!error&&response.statusCode==200){
			if(JSON.parse(body).resultsPage.results.venue){
				var venueId = JSON.parse(body).resultsPage.results.venue[0].id;
				console.log(venueId);
				var upcomingEventsUrl2 = "https://api.songkick.com/api/3.0/venues/"+venueId+"/calendar.json?apikey="+songKickApiKey;
				request(upcomingEventsUrl2,function(error,response,info){
					if(!error&&response.statusCode==200){
						console.log(info);
						res.send(info);
					}
				})
			}
			else{
				res.send("No data");
			}
		}
	})
})

app.get('/testApi',function(req,res){
	console.log(req.query.data1);
	res.send(req.query.data1)
})

app.get('/autocomplete',function(req,res){
	var apiKey = "PVim49x71n5y9vPEDQNBrAfBFnGAkKnm";
	var autoCompleteUrl = "https://app.ticketmaster.com/discovery/v2/suggest?apikey="+apiKey+"&keyword="+req.query.keyword;
	request(autoCompleteUrl,function(error,response,body){
		if(!error&&response.statusCode==200){
			res.send(body);
			console.log("#####");
			console.log(autoCompleteUrl);
		}
	})
})


 
var server = app.listen(8081, function () {
 
  var host = server.address().address
  var port = server.address().port
 
  console.log("访问地址为 http://%s:%s", host, port)
 
})