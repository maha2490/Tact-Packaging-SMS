body {
	z-index: 0;
	background: #eee;
	-webkit-font-smoothing: antialiased;
}
        
.pageContainer{
    margin: 0 auto;
	padding: 10px;
	z-index: 2000;
	overflow: auto; 
}

.myForm{
	position: relative;
	margin: 0 auto;
	background: #FFF;
	border: 1px solid #FFF;
}
        
.myForm h1{
	height: 30px; line-height: 50px;
	padding:10px;
	background: #fff;
	font-size: 24px;
	color: #333333;
	text-align: center;
	text-transform: uppercase;
}
        
.myForm h2{
	height: 20px; line-height: 30px;
	padding-left: 10px;
	padding-right: 10px;
	background: #FFF;
	font-size: 18px;
	color: #333333;
	text-align: center;
	
}

.myForm h3{
	height: 20px; line-height: 30px;
	margin:1px;
	padding:5px;
	background: #EEE;
	font-size: 18px;
	color: #333333;
	text-align: center;
	text-transform: uppercase;
}

.myForm hr{
	height: 1px;
	margin: 0 10px 0 10px;
	color: #eee;
	background-color: #33B5E5;
	border: none;
}       

.myForm textarea {
	width: 50%; height:90px; 
	margin: 1%;
	padding:5px;
	overflow: auto;
	background: #fdfdfd;
	border: 1px solid #eee;
	color: #333333;
	font-size: 12px;
	outline: none;
}
        
.mybutton{
	width:100%; height: 30px; margin:1px;
	background: #FFF!important;
	border: 1px solid #EEE!important;
	border-bottom: 3px solid #EEE!important;
	border-radius: 0px !important;
	cursor: pointer;
	font-size: 16px !important;
	text-transform: uppercase;
	color: #ccc!important;
	text-align: center;    
}
        
.mybutton:hover{
	background: #eee!important;
	border: 1px solid #EEE!important;
	border-bottom: 3px solid #33B5E5!important;
	border-radius: 0px !important;
	color: #33B5E5!important;  
	opacity: 0.8;    filter:alpha(opacity=80);    -moz-opacity:0.8;     -khtml-opacity: 0.8;  
}
        
.mybutton:active{
	width:100%; height: 30px; margin:1px;
	background: #33B5E5!important;
	border: 0px solid #EEE!important;
	border-bottom: 0px solid #33B5E5!important;
	border-radius: 0px !important;
	cursor: pointer;
	font-size: 16px !important;
	color: #FFF!important;
	text-transform: uppercase;
	text-align: center;
	opacity: 0.8;    filter:alpha(opacity=80);    -moz-opacity:0.8;     -khtml-opacity: 0.8;     
}

.popupBackground{
   top:0; left:0; height:100%; width:100%; z-index:1000;
   position:fixed;    
   background-color:#000000;   
   opacity: 0.3;    filter:alpha(opacity=30);    -moz-opacity:0.3;     -khtml-opacity: 0.3;
}
.popupBox{
	top:10%; left:10%; width:80%; min-height:60%; max-height:80%; z-index:3000;
	position:fixed; 
	text-align:left;
	overflow:auto;    
	color:#2F4F4F;    
	background-color:#ffffff;    border: 2px solid #FFFFFF !important;
}

.tdCol1{ 
	padding:3px!important; text-align:left;
	background: #F8F8F8!important;  
	border: 1px solid #FFFFFF !important;
	font-weight:bold !important;    
}
.tdCol2{    
	padding:3px!important;
	background: #EFF5FB!important; 
	border: 1px solid #FFFFFF !important; 
	font-weight:bold !important;
}
.tdCol3{ 
	padding:3px!important; text-align:center;
	background: #F8F8F8!important;  
	border: 1px solid #FFFFFF !important;
	font-weight:bold !important;    
}