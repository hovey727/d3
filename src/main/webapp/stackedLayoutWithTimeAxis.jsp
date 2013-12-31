<?xml version="1.0" encoding="UTF-8" ?>
<%@ taglib prefix="s" uri="/struts-tags"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<script type="text/javascript" src="js/d3.js"></script>

<style type="text/css">
body {
	overflow: hidden;
	margin: 0;
	font-size: 14px;
	font-family: "Helvetica Neue", Helvetica;
}

#chart,#header,#footer {
	position: absolute;
	top: 0;
}

#header,#footer {
	z-index: 1;
	display: block;
	font-size: 36px;
	font-weight: 300;
	text-shadow: 0 1px 0 #fff;
}

#header.inverted,#footer.inverted {
	color: #fff;
	text-shadow: 0 1px 4px #000;
}

#header {
	top: 80px;
	left: 140px;
	width: 1000px;
}

#footer {
	top: 680px;
	right: 140px;
	text-align: right;
}

rect {
	fill: none;
	pointer-events: all;
}

pre {
	font-size: 18px;
}

line {
	stroke: #000;
	stroke-width: 1.5px;
}

.string,.regexp {
	color: #f39;
}

.keyword {
	color: #00c;
}

.comment {
	color: #777;
	font-style: oblique;
}

.number {
	color: #369;
}

.class,.special {
	color: #1181B8;
}

a:link,a:visited {
	color: #000;
	text-decoration: none;
}

a:hover {
	color: #666;
}

.hint {
	position: absolute;
	right: 0;
	width: 1000px;
	font-size: 12px;
	color: #999;
}

#footer .times {
	font-size: 15px;
}

#footer .legend {
	font-size: 30px;
	font-style: bold;
}

svg {
	font-size: 10px;
}

rect {
	fill: #eeeeee;
}

path.area {
	fill: #000;
	fill-opacity: .75;
}

.axis line,.grid line {
	stroke-width: .5px;
	shape-rendering: crispEdges;
}

.grid line {
	stroke: #fff;
}

.grid line.minor {
	stroke-opacity: .5;
}

.grid text {
	display: none;
}

.axis line {
	stroke: #000;
}

.grid path,.axis path {
	display: none;
}
</style>
</head>
<body>
	<div id="chart">
		<div id="footer">
			<div class="title">Ireland Power [MW]</div>
			<div class="legend"></div>
			<div class="times"></div>
			<div class="hint">click or option-click to toggle zoom</div>
		</div>
	</div>
	<script type="text/javascript" src="js/slwta.js"></script>
</body>
</html>