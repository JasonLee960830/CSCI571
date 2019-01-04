
<?php
include "./geoHash.php";
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // collect value of input field
    $keyword = $_POST['keyword'];
    $category = $_POST['category'];
    if($_POST['distance']=="")
        $distance = 10;
    else{
        $distance = $_POST['distance'];
    }
    if($_POST['position']=="location") {
        //后端发送geocode请求
        $ch = curl_init();
        $timeout = 5;
        $geocodeUrl = "https://maps.googleapis.com/maps/api/geocode/json?address=" . urlencode($_POST['customized_location']) . "&key=AIzaSyC7tqbcASHS3luuZS5D3rH0sR6owqPtofU";
        curl_setopt($ch, CURLOPT_URL, $geocodeUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
        $geocode_contents = curl_exec($ch);
        $geocode_contents = json_decode($geocode_contents, true);
        curl_close($ch);

        //存储自定义位置的经纬值
        $customized_lat = $geocode_contentsl;
        $customized_lng = $geocode_contents['results'][0]['geometry']['location']['lng'];
        echo '<div id="customized_lat" >'.$customized_lat.'</div>';
        echo '<div id="customized_lng" >'.$customized_lng.'</div>';
        $geoPoint = encode($customized_lat, $customized_lng, 5);
    }
    else{
        $geoPoint = encode($_POST['hidden_latitude'], $_POST['hidden_longitude'], 5);
    }

    switch ($category)
    {
        case 'Music':
            $segmentId = "KZFzniwnSyZfZ7v7nJ";
            break;
        case 'Sports':
            $segmentId = "KZFzniwnSyZfZ7v7nE";
            break;
        case 'Arts':
            $segmentId = "KZFzniwnSyZfZ7v7na";
            break;
        case 'Theatre':
            $segmentId = "KZFzniwnSyZfZ7v7na";
            break;
        case 'Film':
            $segmentId = "KZFzniwnSyZfZ7v7nn";
            break;
        case 'Miscellaneous':
            $segmentId ="KZFzniwnSyZfZ7v7n1";
            break;
        default:
            $segmentId = "";
    }

    $ch = curl_init();
    $timeout = 5;
    $eventUrl="https://app.ticketmaster.com/discovery/v2/events.json?apikey=PVim49x71n5y9vPEDQNBrAfBFnGAkKnm&keyword=".$keyword."&segmentId=".$segmentId."&radius=".$distance."&unit=miles&geoPoint=".$geoPoint;
    curl_setopt ($ch, CURLOPT_URL, $eventUrl);
    curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt ($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
    $event_contents = curl_exec($ch);
    $event_contents = json_decode($event_contents,true);
    curl_close($ch);
    $event_show = array();
    if(isset($event_contents['_embedded']['events'])) {
        for ($i = 0; $i <count($event_contents['_embedded']['events']); $i++ ){
            if($event_contents['_embedded']['events'][$i]['dates']['start']['localDate'])
                $event_show['event'][$i]['date'][0] = $event_contents['_embedded']['events'][$i]['dates']['start']['localDate'];
            if(isset($event_contents['_embedded']['events'][$i]['dates']['start']['localTime']))
                $event_show['event'][$i]['date'][1] = $event_contents['_embedded']['events'][$i]['dates']['start']['localTime'];
            if($event_contents['_embedded']['events'][$i]['images'][0]['url'])
                $event_show['event'][$i]['icon'] = $event_contents['_embedded']['events'][$i]['images'][0]['url'];
            if($event_contents['_embedded']['events'][$i]['name']) {
                $replacedName = $event_contents['_embedded']['events'][$i]['name'];
                $replacedName = str_replace("'", "^", $replacedName);
                $event_show['event'][$i]['name'] = $replacedName;
            }
            if(isset($event_contents['_embedded']['events'][$i]['classifications'][0]['segment']['name']))
                $event_show['event'][$i]['genre'] = $event_contents['_embedded']['events'][$i]['classifications'][0]['segment']['name'];
            if(isset($event_contents['_embedded']['events'][$i]['_embedded']['venues'][0]['name']))
                $event_show['event'][$i]['venue'] = $event_contents['_embedded']['events'][$i]['_embedded']['venues'][0]['name'];
            if( $event_contents['_embedded']['events'][$i]['id'])
                $event_show['event'][$i]['id'] = $event_contents['_embedded']['events'][$i]['id'];
        }
    }
    $event_show = json_encode($event_show);

    $_POST['event_show'] = $event_show;
    echo '<div id="event_show">'.$event_show.'</div>';
    if($_POST['detail_info']!='') {
        $ch = curl_init();
        $timeout = 1;
        $eventUrl="https://app.ticketmaster.com/discovery/v2/events/".$_POST['detail_info'].".json?apikey=PVim49x71n5y9vPEDQNBrAfBFnGAkKnm";
        //echo $eventUrl;
        curl_setopt ($ch, CURLOPT_URL, $eventUrl);
        curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt ($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
        $event_contents = curl_exec($ch);
        $event_contents = json_decode($event_contents,true);
        $event_detail['detail']['name'] = $event_contents['name'];
        $event_detail['detail']['date'][0] = $event_contents['dates']['start']['localDate'];
        $event_detail['detail']['date'][1] = $event_contents['dates']['start']['localTime'];
        if(isset($event_contents['_embedded']['attractions'][0])) {
            for ($i = 0; $i < count($event_contents['_embedded']['attractions']); $i++) {
                $event_detail['detail']['artist'][$i] = $event_contents['_embedded']['attractions'][$i]['name'];
                $event_detail['detail']['artistUrl'][$i] = $event_contents['_embedded']['attractions'][$i]['url'];
            }
        }
        $event_detail['detail']['venue'] = $event_contents['_embedded']['venues'][0]['name'];
        if(isset($event_contents['classifications'][0])) {
            if(isset($event_contents['classifications'][0]['subGenre']))
                $event_detail['detail']['Genre'][0] = $event_contents['classifications'][0]['subGenre']['name'];
            if(isset($event_contents['classifications'][0]['genre']))
                $event_detail['detail']['Genre'][1] = $event_contents['classifications'][0]['genre']['name'];
            if(isset($event_contents['classifications'][0]['segment']))
                $event_detail['detail']['Genre'][2] = $event_contents['classifications'][0]['segment']['name'];
            if(isset($event_contents['classifications'][0]['subType']))
                $event_detail['detail']['Genre'][3] = $event_contents['classifications'][0]['subType']['name'];
            if(isset($event_contents['classifications'][0]['type']))
                $event_detail['detail']['Genre'][4] = $event_contents['classifications'][0]['type']['name'];
        }
        if(isset($event_contents['priceRanges'][0]['min']))
            $event_detail['detail']['priceRange'][0] = $event_contents['priceRanges'][0]['min'];
        if(isset($event_contents['priceRanges'][0]['max'])){
            $event_detail['detail']['priceRange'][1] = $event_contents['priceRanges'][0]['max'];
            //echo $event_detail['detail']['priceRange'][1];
        }

        $event_detail['detail']['ticketStatus'] = $event_contents['dates']['status']['code'];
        $event_detail['detail']['buyTicketAt'] = $event_contents['url'];
        if(isset($event_contents['seatmap']['staticUrl'])) {
            $event_detail['detail']['seatMap'] = $event_contents['seatmap']['staticUrl'];
        }
        $event_detail = json_encode($event_detail);
        //echo '<div id="event_details" >'.$_POST['detail_info'].'</div>';
        echo '<div id="event_details" >'.$event_detail.'</div>';
        sleep(2);
        $str = str_replace(' ', '%20', $event_contents['_embedded']['venues'][0]['name']);
        $venueUrl = "https://app.ticketmaster.com/discovery/v2/venues?apikey=PVim49x71n5y9vPEDQNBrAfBFnGAkKnm&keyword=".$str;
        curl_setopt ($ch, CURLOPT_URL, $venueUrl);
        curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt ($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
        $venue_contents = curl_exec($ch);
        $venue_contents = json_decode($venue_contents,true);
        curl_close($ch);
        if(isset($venue_contents['_embedded']['venues'][0]['name']))
        $venue_details['detail']['name'] =$venue_contents['_embedded']['venues'][0]['name'];
        if(isset($venue_contents['_embedded']['venues'][0]['location']))
        $venue_details['detail']['longitude']=$venue_contents['_embedded']['venues'][0]['location']['longitude'];
        if(isset($venue_contents['_embedded']['venues'][0]['location']))
        $venue_details['detail']['latitude']=$venue_contents['_embedded']['venues'][0]['location']['latitude'];
        if(isset($venue_contents['_embedded']['venues'][0]['address']))
        $venue_details['detail']['address']=$venue_contents['_embedded']['venues'][0]['address']['line1'];
        if(isset($venue_contents['_embedded']['venues'][0]['city']))
        $venue_details['detail']['city']=$venue_contents['_embedded']['venues'][0]['city']['name'];
        if(isset($venue_contents['_embedded']['venues'][0]['state']))
        $venue_details['detail']['stateCode']=$venue_contents['_embedded']['venues'][0]['state']['stateCode'];
        if(isset($venue_contents['_embedded']['venues'][0]['postalCode']))
        $venue_details['detail']['postalCode']=$venue_contents['_embedded']['venues'][0]['postalCode'];
        if(isset($venue_contents['_embedded']['venues'][0]['url']))
        $venue_details['detail']['upcoming']=$venue_contents['_embedded']['venues'][0]['url'];
        $j=0;
        if(isset($venue_contents['_embedded']['venues'][0]['images'])) {
            for ($i = 0; $i < count($venue_contents['_embedded']['venues'][0]['images'][0]); $i++) {
                if (isset($venue_contents['_embedded']['venues'][0]['images'][$i]['url'])) {
                    $venue_details['detail']['photo'][$j] = $venue_contents['_embedded']['venues'][0]['images'][$i]['url'];
                    $j = $j + 1;
                }
            }
        }
        if(isset($venue_details)) {
            $venue_details = json_encode($venue_details);
            echo '<div id="venue_details" >' . $venue_details . '</div>';
        }
        else{
            echo '<div id="venue_details" >NO RECORDS</div>';
        }
    }
    if($_POST['venueMapInfo']!=''){
        $ch = curl_init();
        $timeout = 5;
        $eventUrl="https://app.ticketmaster.com/discovery/v2/events/".$_POST['venueMapInfo'].".json?apikey=PVim49x71n5y9vPEDQNBrAfBFnGAkKnm";
        //echo $eventUrl;
        curl_setopt ($ch, CURLOPT_URL, $eventUrl);
        curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt ($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
        $event_contents = curl_exec($ch);
        $event_contents = json_decode($event_contents,true);
        curl_close($ch);


        sleep(2);
        $ch = curl_init();
        $timeout = 1;
        $str = str_replace(' ', '%20', $event_contents['_embedded']['venues'][0]['name']);
        $venueUrl = "https://app.ticketmaster.com/discovery/v2/venues?apikey=PVim49x71n5y9vPEDQNBrAfBFnGAkKnm&keyword=".$str;
        curl_setopt ($ch, CURLOPT_URL, $venueUrl);
        curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt ($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
        $venue_contents = curl_exec($ch);
        //echo $event_contents;
        $venue_contents = json_decode($venue_contents,true);
        curl_close($ch);
        $outputVenueMapInfo['longitude']=$venue_contents['_embedded']['venues'][0]['location']['longitude'];
        $outputVenueMapInfo['latitude']=$venue_contents['_embedded']['venues'][0]['location']['latitude'];
        $outputVenueMapInfo['index']=$_POST['Index'];
        $outputVenueMapInfo = json_encode($outputVenueMapInfo);
        echo '<div id="outputVenueMapInfo">'.$outputVenueMapInfo.'</div>';
        echo '<div id="locateMap"><div id="mapinfo"><div id="mode"><div id="walk">walk there</div><div id="bike">bike there</div><div id="drive">drive there</div></div><div id="map"></div></div></div>';
    }
    }
?>
<!DOCTYPE html>
<html>
<head>
    <title> Homework 6</title>

        <style type="text/css">
            body{
            }
            #searchBox{
                border:2px solid;
                border-color: grey;
                width:50%;
                margin:auto;
                padding:10px;
                margin-bottom: 25px;
            }
            #noRecordFound{
                display:none;
                text-align: center;
                background: darkgrey;
                width:70%;
                margin: auto;
            }
            #heading{
                text-align:center;
            }
            #custom_radio{
                margin-left:50%;
            }
            #submit{
                margin-left:20%;
            }
            #event_details{
                display:none;
            }
            #venue_details{
                display:none;
            }
            .info{
                font-weight: bold;
            }
            #Result{
                width: 90%;
            }
            #leftResult{
                float: left;
                width: 40%;
            }
            #rightResult{
                float: right;
            }
            #detail_block{
                width:70%;
                margin: auto;
                height:600px;
            }
            #detail_block h2{
                text-align: center;
            }
            #detail_block img{
                width:400px;
                height: 300px;
            }
            #venue_block{
                margin:auto;
                width:90%;
                height: 620px;
                border:0px;
                border-collapse: collapse;
                text-align: center;
                border-color: gainsboro;
            }
            #outputForm{
                width:85%;
                margin: auto;
            }
            table{
                display: inline-block;
            }
            #venue_block .info{
                font-weight: bold;
            }
            #mode{
                float:left;
                background: darkgrey;
            }
            #mode div:hover{
                color: grey;
            }
            #map{
                width: 350px;
                height: 350px;
                background-color: grey;
                display: none;
                float:right;
             }
            #locateMap{
                width:450px;
                z-index: 3;
                position: absolute;
                right: 0px;
            }
            /*#route{*/
                /*float:left*/
            /*}*/
            #mapinfo{
                height:400px;
            }
            #venue_photo{
                width:80%;
                margin: auto;
            }
            #venue_photo img{
                width: 70%;
                height: 300px;
            }
            #customized_lat{
                display:none;
            }
            #customized_lng{
                display:none;
            }
            #event_show{
                display:none;
            }
            a:hover {
                color:grey;
                cursor: pointer;
            }
            a{
                color:black;
                text-decoration: none;
            }
            .venue:hover {
                color:grey;
                cursor: pointer;
            }
            #venueMode1{
                display:none;
                text-align: center;
            }
            #venueMode2{
                display:none;
                text-align: center;
            }
            #infoDesc{
                text-align: center;
                color:grey;
            }
            #photoDesc{
                text-align:center;
                color:grey;
            }
            #infoButton{
                margin: auto;
                text-align: center;
            }
            #photoButton{
                margin: auto;
                text-align: center;
            }
            button img{
                width: 20px;
                height: 10px;
            }
            #hid_latitude{
                display:none;
            }
            #hid_longitude{
                display:none;
            }
            #outputVenueMapInfo{
                display: none;
            }

        </style>

    <script type="text/javascript">
        function getLocation(){
                var xmlhttp= new XMLHttpRequest();
                xmlhttp.open("GET","http://ip-api.com/json",false);
                xmlhttp.send();
                if(xmlhttp.status==404){ //url不存在
                    alert(" locating failed.");
                }
                else{
                    var json=JSON.parse(xmlhttp.responseText);
                    currentLongitude=json['lon'];
                    currentLatitude=json['lat'];
                    uluru={
                        lat:currentLatitude,
                        lng:currentLongitude
                    };
                    document.getElementById("hidden_longitude").value=currentLongitude;
                    document.getElementById("hidden_latitude").value=currentLatitude;
                    document.getElementById("hid_latitude").innerText=currentLatitude;
                    document.getElementById("hid_longitude").innerText=currentLongitude;
                    document.getElementById("Submit").removeAttribute('disabled');
            }

        }
        function validateLocation(){
            if(document.getElementById("custom_radio").checked==true){
                document.getElementById("customized_location").disabled=false;
                document.getElementById("customized_location").required=true;
            }
            else{
                document.getElementById("customized_location").disabled=true;
                document.getElementById("customized_location").required=false;
            }
        }


        function clearForm() {

            document.getElementById("distance").value = "";
            document.getElementById("here").checked = true;
            document.getElementById("customized_location").value = "";
            document.getElementById("keyword").value="";
            document.getElementById("category").options[0].selected = true;
            //make the first page information invisible(1 part)
            document.getElementById("outputForm").style.display="none";

            //make the second page information invisible(3 parts)
            document.getElementById("detail_block").style.display="none";
            document.getElementById("venueMode1").style.display="none";
            document.getElementById("venueMode2").style.display="none";

            //make the No Record Hint invisible
            document.getElementById("noRecordFound").style.display="none";
        }
        function toggleInfo(){
            if(document.getElementById("infoDesc").innerText=="click to show venue info"){
                document.getElementById(("infoDesc")).innerText="click to hide venue info";
                document.getElementById("venue_block").style.display="block";
                document.getElementById("upButton").src ="https://cdn3.iconfinder.com/data/icons/mixed-ui-icons-3-1/96/Untitled-52-512.png";
            }
            else{
                document.getElementById(("infoDesc")).innerText="click to show venue info";
                document.getElementById("venue_block").style.display="none";
                document.getElementById("upButton").src = "https://cdn3.iconfinder.com/data/icons/mixed-ui-icons-3-1/96/Untitled-54-512.png";
            }
        }
        function togglePhoto(){
            if(document.getElementById("photoDesc").innerText=="click to show venue photo"){
                document.getElementById(("photoDesc")).innerText="click to hide venue photo";
                document.getElementById("venue_photo").style.display="block";
                document.getElementById("downButton").src ="https://cdn3.iconfinder.com/data/icons/mixed-ui-icons-3-1/96/Untitled-52-512.png";
            }
            else{
                document.getElementById(("photoDesc")).innerText="click to show venue photo";
                document.getElementById("venue_photo").style.display="none";
                document.getElementById("downButton").src = "https://cdn3.iconfinder.com/data/icons/mixed-ui-icons-3-1/96/Untitled-54-512.png";
            }
        }
        function getDetails(index) {
             var id = event_show['event'][index]['id'];
            document.getElementById("detail_info").value = id;
            document.getElementById("inputForm").submit();
        }
        function getVenueMapInfo(index){
            var id = event_show['event'][index]['id'];
            document.getElementById("venueMapInfo").value = id;
            document.getElementById("Index").value = index;

            document.getElementById("inputForm").submit();
        }
        function chooseWalkMode(){
            return "WALKING";
        }
        function chooseBikeMode(){
            return "BICYCLING";
        }
        function chooseDriveMode(){
            return "DRIVING";
        }
        function initMapWithDirection() {
            var directionsDisplay = new google.maps.DirectionsRenderer;
            var directionsService = new google.maps.DirectionsService;
            //var uluru;
            if(document.getElementById("here").checked==true){
                getLocation();

            }
            else {
                uluru = {
                    lat: parseFloat(document.getElementById("customized_lat").innerText),
                    lng: parseFloat(document.getElementById("customized_lng").innerText)
                };

            }
            var map = new google.maps.Map(document.getElementById('map'), {
                zoom: 14,
                center: uluru
            });
            directionsDisplay.setMap(map);
            var marker = new google.maps.Marker({position: uluru, map: map});


            calculateAndDisplayRoute(directionsService, directionsDisplay,uluru);
            document.getElementById('walk').addEventListener('click', function() {
                calculateAndDisplayRoute(directionsService, directionsDisplay,"WALKING");
            });
            document.getElementById('bike').addEventListener('click', function() {
                calculateAndDisplayRoute(directionsService, directionsDisplay,"BICYCLING");
            });
            document.getElementById('drive').addEventListener('click', function() {
                calculateAndDisplayRoute(directionsService, directionsDisplay,"DRIVING");
            });
        }
        function calculateAndDisplayRoute(directionsService, directionsDisplay,selectedMode) {
            if(document.getElementById("here").checked==true){
                uluru= {
                    lat: parseFloat(document.getElementById("hid_latitude").innerText),
                    lng: parseFloat(document.getElementById("hid_longitude").innerText)
                };
            }
            else {
                uluru = {
                    lat:parseFloat(document.getElementById("customized_lat").innerText),lng:parseFloat(document.getElementById("customized_lng").innerText)
                };
            }
            if(document.getElementById("outputVenueMapInfo")) {

                document.getElementById("map").style.display = "block";
                document.getElementById("mapinfo").style.position = "absolute";
                var mapHeight = 350 + parseFloat(JSON.parse(document.getElementById("outputVenueMapInfo").innerText).index) * 75;
                document.getElementById("mapinfo").style.top = mapHeight + "px";
                document.getElementById("mode").style.position="absolute";
                document.getElementById("mode").style.zIndex="4";
                document.getElementById("mode").style.top="50px";
                end = {
                    lat: parseFloat(JSON.parse(document.getElementById("outputVenueMapInfo").innerText).latitude),
                    lng: parseFloat(JSON.parse(document.getElementById("outputVenueMapInfo").innerText).longitude)
                }
                document.getElementById("body").addEventListener("click", function () {
                    document.getElementById("mapinfo").style.display = "none";
                });

            }
            else {
                end = {
                    lat: parseFloat(venue_block['detail']['latitude']),
                    lng: parseFloat(venue_block['detail']['longitude'])
                }
            }
            directionsService.route({
                origin: uluru,
                destination: end,
                travelMode: google.maps.TravelMode[selectedMode]
            }, function(response, status) {
                if (status == 'OK') {
                    directionsDisplay.setDirections(response);
                } else {
                    window.alert('Directions request failed due to ' + status);
                }
            });
        }
    </script>
</head>
<body onload="getLocation()">
<div id="body">
<div id="hid_latitude"></div>
<div id="hid_longitude"></div>
<div id="searchBox">
    <div id="heading">Event Search</div>
    <hr style="color: grey">
    <form id="inputForm" action="<?php echo $_SERVER['PHP_SELF'] ?>" method="post">

        <item>Keyword:</item> <input id="keyword" type="text" name="keyword" value="<?php if(isset($_POST['keyword'])){echo $_POST['keyword'];}?>" required oninvalid="setCustomValidity('please fill out this field')" oninput="setCustomValidity('')"><br>

        <item>Category:</item>
        <?php $select_value = isset($_POST['category']) ? $_POST['category'] : ''; ?>
        <select id="category" name="category" value="<?php if(isset($_POST['category'])){echo $_POST['category'];}?>">
            <option value="Default" selected>Default</option>
            <option value="Music" <?php echo $select_value == 'Music' ? 'selected' : '' ?>>Music</option>
            <option value="Sports" <?php echo $select_value == 'Sports' ? 'selected' : '' ?>>Sports</option>
            <option value="Arts" <?php echo $select_value == 'Arts' ? 'selected' : '' ?>>Arts</option>
            <option value="Theatre" <?php echo $select_value == 'Theatre' ? 'selected' : '' ?>>Theatre</option>
            <option value="Film" <?php echo $select_value == 'Film' ? 'selected' : '' ?>>Film</option>
            <option value="Miscellaneous" <?php echo $select_value == 'Miscellaneous' ? 'selected' : '' ?>>Miscellaneous</option>
        </select><br>

        <item>Distance:(miles)</item>  <input id="distance" type="text" name="distance" placeholder="10" value="<?php if(isset($_POST['distance'])){echo $_POST['distance'];}?>">

        <item>from:</item>
            <input id="here" type="radio" name="position" value="Here" onclick="validateLocation()" checked>Here<br>

            <input type="hidden" type="text" name="hidden_longitude" id="hidden_longitude">
            <input type="hidden" type="text" name="hidden_latitude" id="hidden_latitude">
            <?php $select_position = isset($_POST['position']) ? $_POST['position'] : ''; ?>

            <input id="custom_radio" type="radio" name="position" value="location" <?php echo $select_position == 'location' ? 'checked' : '' ?> onclick="validateLocation()">
            <input id="customized_location" type="text" disabled=true name="customized_location" placeholder="location" value="<?php if(isset($_POST['customized_location'])){echo $_POST['customized_location'];}?>" ><br>

        <div><input id="Submit" disabled type="submit" name="Search" value="Search"> <input  onclick="clearForm()" type="button"  name="Clear" value="Clear"></div>
        <input type="hidden" type="text" name="detail_info" id="detail_info" value="">
        <input type="hidden" type="text" name="venueMapInfo" id="venueMapInfo" value="">
        <input type="hidden" type="text" name="Index" id="Index" value="">
    </form>
</div>
<div id="noRecordFound"></div>
<div id ="outputForm">

</div>
<div id="placeMap"></div>
<div id="detail_block">
<!--event block-->
</div>

<div id="venueMode1">

    <div id="infoDesc">click to show venue info</div>
    <div id="infoButton">
        <button onclick="toggleInfo()"><img id="upButton" src="https://cdn3.iconfinder.com/data/icons/mixed-ui-icons-3-1/96/Untitled-54-512.png"></button>
    </div>

    <div id="venue_block">
    </div>
</div>

<div id="venueMode2">
    <div id="photoDesc">click to show venue photo</div>
    <div id="photoButton">
        <button  onclick="togglePhoto()"><img id="downButton" src="https://cdn3.iconfinder.com/data/icons/mixed-ui-icons-3-1/96/Untitled-54-512.png"></button>
    </div>
    <div id="venue_photo">
    </div>
</div>
    <input type="hidden" type="text" name="map_latitude" id="map_latitude" value="0">
    <input type="hidden" type="text" name="map_longitude" id="map_longitude" value="0">
    </div>
</body>

<script type="text/javascript">
    if(document.getElementById("custom_radio").checked==true){
        document.getElementById("customized_location").disabled=false;
    }
    if(JSON.parse(document.getElementById("event_show").innerText).length!=0) {
         event_show = document.getElementById("event_show").innerText;
         event_show = JSON.parse(event_show);
        html_text="<table border='1'><tr>";
        var header=["Date","Icon","Event","Genre","Venue"];
        for(i=0;i<header.length;i++){
            html_text+="<th>"+header[i]+"</th>";
        }
        html_text+="</tr>";
        for(j=0;j<event_show['event'].length;j++){
            var item="";
            item+="<tr>"+"<td>";
            if(event_show['event'][j]['date'][0]!=undefined)
                item+="<div>"+event_show['event'][j]['date'][0]+"</div>";
            if(event_show['event'][j]['date'][1]!=undefined)
                item+="<div>"+event_show['event'][j]['date'][1]+"</div>";
            item+="</td>";
            item+="<td>"+"<img width=50px;height=50px; src='"+event_show['event'][j]['icon']+"'>"+"</td>";
            var str = event_show['event'][j]['name'];
            str=str.replace(/\^/g,'\'');
            item+="<td>"+"<a onclick='getDetails("+j+")'>"+str+"</a></td>";
            if(!event_show['event'][j]['genre'])
                event_show['event'][j]['genre']="N/A";
            item+="<td>"+event_show['event'][j]['genre']+"</td>";
            item+="<td><div class='venue' onclick='getVenueMapInfo("+j+")'>"+event_show['event'][j]['venue']+"</div></td>";
            item+="</tr>";
            html_text+=item;
        }
        html_text+="</table>";
        document.getElementById("outputForm").innerHTML = html_text;
    }
    else if(document.getElementById("event_show")){
        document.getElementById("noRecordFound").innerText="No Records has been found";
        document.getElementById("noRecordFound").style.display="block";
    }
    if(document.getElementById("event_details").innerText!=""){
        document.getElementById("outputForm").style.display="none";
        detail_block = JSON.parse(document.getElementById('event_details').innerText);
        search_result = "";

        search_result+="<div id='Result'>"+"<h2>"+detail_block['detail']['name']+"</h2>"+"<div id='leftResult'>";
        if(detail_block['detail']['date']) {
            search_result += "<div class='info'>" + "Date" + "</div>";
            search_result += "<div>" + detail_block['detail']['date'][0] + " " + detail_block['detail']['date'][1] + "</div>";
        }
            if(detail_block['detail']['artistUrl']) {
                search_result+="<div class='info'>"+"Artist/Team"+"</div>";
                search_result+="<div>";
                search_result += "<a href='" + detail_block['detail']['artistUrl'][0] + "' target='_blank'>" + detail_block['detail']['artist'][0] + "</a>";
                for (i = 1; i < detail_block['detail']['artist'].length; i++)
                    search_result += "|" + "<a href='" + detail_block['detail']['artistUrl'][i] + "' target='_blank'>" + detail_block['detail']['artist'][i] + "</a>";
                search_result+="</div>";
            }
            if(detail_block['detail']['venue']) {
                search_result += "<div class='info'>" + "Venue" + "</div>";
                search_result += "<div>" + detail_block['detail']['venue'] + "</div>";
            }
            if(detail_block['detail']['Genre']) {
                search_result += "<div class='info'>" + "Genres" + "</div>";
                i = 0;
                search_result += "<div>";
                search_result += detail_block['detail']['Genre'][0];
                for (i = 1; i < detail_block['detail']['Genre'].length; i++) {
                    if(detail_block['detail']['Genre'][i]=="Undefined")
                        continue;
                    search_result += "|" + detail_block['detail']['Genre'][i];
                }
                search_result += "</div>";
            }
            if(detail_block['detail']['priceRange']) {
                search_result += "<div class='info'>" + "Price Ranges" + "</div>";
                if (detail_block['detail']['priceRange'][0]&&!detail_block['detail']['priceRange'][1]){
                        search_result += "<div>Min_price: " + detail_block['detail']['priceRange'][0] + " USD</div>";
                }
                else if(detail_block['detail']['priceRange'][1]&&!detail_block['detail']['priceRange'][0]){
                        search_result += "<div>Max_price: " + detail_block['detail']['priceRange'][1] + " USD</div>";
                }
                else{
                    search_result += "<div> " + detail_block['detail']['priceRange'][0]+"-"+detail_block['detail']['priceRange'][1]+ " USD</div>";
                }
            }
            if(detail_block['detail']['ticketStatus']) {
                search_result += "<div class='info'>" + "Ticket Status" + "</div>";
                search_result += "<div>" + detail_block['detail']['ticketStatus'] + "</div>";
            }
            if(detail_block['detail']['buyTicketAt']) {
                search_result += "<div class='info'>" + "Buy Ticket At" + "</div>";
                search_result += "<div>" + "<a href='" + detail_block['detail']['buyTicketAt'] + "' target='_blank'>" + "TicketMaster" + "</a>" + "</div>";

            }
        search_result += "</div>";
        if(detail_block['detail']['seatMap']!=undefined) {
            document.getElementById("detail_block").innerHTML = search_result;
            search_result+="<div id = 'rightResult'>";
            search_result += "<img src='" + detail_block['detail']['seatMap'] + "'>";
            search_result+="</div></div>";
            document.getElementById("detail_block").innerHTML = search_result;
        }
        else{
            search_result+="</div>";
            document.getElementById("detail_block").innerHTML = search_result;
            document.getElementById("detail_block").style.textAlign="center";
            document.getElementById("leftResult").style.width=900+"px";
        }
    }
    if(document.getElementById("venue_details").innerText!=""&&document.getElementById("venue_details").innerText!="NO RECORDS") {
        venue_block = JSON.parse(document.getElementById("venue_details").innerText);
        venue_html = "<table border='1'>";
        venue_html += "<tr>" + "<td class='info'>Name</td>" + "<td>" + venue_block['detail']['name'] + "</td>" + "</tr>";
        //venue_html+="<tr>"+"<td class='info'>Map</td>"+"<td id='mapinfo'>"+"<div id='map'></div>"+"<select id='mode'>"+"+<option value='WALKING' id='walk'>walk there</option>"+"<option value='BICYCLING' id='bike'>bike there</option>"+"<option value='DRIVING' id='drive'>drive there</option>"+"</select>"+"</td>"+"</tr>";
        venue_html += "<tr>" + "<td class='info'>Map</td>" + "<td id='mapinfo'>" + "<div id='map'></div>" + "<div id='mode'>" + "<div id='walk'>walk there</div>" + "<div id='bike'>bike there</div>" + "<div id='drive'>drive there</div>" + "</div>" + "</td>" + "</tr>";
        venue_html += "<tr>" + "<td class='info'>Address</td>" + "<td>" + venue_block['detail']['address'] + "</td>" + "</tr>";
        venue_html += "<tr>" + "<td class='info'>City</td>" + "<td>" + venue_block['detail']['city'] + venue_block['detail']['stateCode'] + "</td>" + "</tr>";
        venue_html += "<tr>" + "<td class='info'>Postal Code</td>" + "<td>" + venue_block['detail']['postalCode'] + "</td>" + "</tr>";
        venue_html += "<tr>" + "<td class='info'>Upcoming Events</td>" + "<td>" + "<a href='"+venue_block['detail']['upcoming']+"' target='_blank'>"+venue_block['detail']['name']+" Tickets"+ "</a>"+ "</td>" + "</tr>";
        venue_html += "</table>";
        document.getElementById("venue_block").innerHTML = venue_html;
        document.getElementById("map_latitude").value = venue_block['detail']['latitude'];
        document.getElementById("map_longitude").value = venue_block['detail']['longitude'];
        document.getElementById("map").style.display = "inline";
        venue_photo = "";
        if(venue_block['detail']['photo']) {
            for (i = 0; i < venue_block['detail']['photo'].length; i++) {
                venue_photo += "<img src='" + venue_block['detail']['photo'][i] + "'>";
            }
        }
        else{
            venue_photo+="No venue photo";
            document.getElementById("venue_photo").style.width="150px";
            document.getElementById("venue_photo").style.background="darkgrey";
        }
        document.getElementById("venue_photo").innerHTML = venue_photo;
        document.getElementById("venueMode1").style.display="block";
        document.getElementById("venueMode2").style.display="block";
        document.getElementById("venue_block").style.display="none";
        document.getElementById("venue_photo").style.display="none";
    }
    else if(document.getElementById("venue_details").innerText=="NO RECORDS"){
        document.getElementById("venue_photo").innerHTML = "No venue photo found";
        document.getElementById("venue_block").innerHTML = "No venue info found";
        document.getElementById("venue_block").style.height="30px";
        document.getElementById("venueMode1").style.display="block";
        document.getElementById("venueMode2").style.display="block";
        document.getElementById("venue_block").style.display="none";
        document.getElementById("venue_photo").style.display="none";
        document.getElementById("venue_photo").style.width="300px";
        document.getElementById("venue_photo").style.background="darkgrey";
        document.getElementById("venue_block").style.width="300px";
        document.getElementById("venue_block").style.background="darkgrey";
    }
</script>
<script type="text/javascript"  src="https://maps.googleapis.com/maps/api/js?key=AIzaSyC7tqbcASHS3luuZS5D3rH0sR6owqPtofU&callback=initMapWithDirection">
    </script>
</html>