<?xml version="1.0" encoding="UTF-8" ?>
<%@ taglib prefix="s" uri="/struts-tags"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<script type="text/javascript" src="js/d3.js"></script>

<link type="text/css" rel="stylesheet" href="style.css" />
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
	<script type="text/javascript">
		var m = [ 79, 80, 160, 79 ], w = 1000 - m[1] - m[3], h = 500 - m[0]
				- m[2], parse = d3.time.format("%Y-%m-%d %H:%M:%S").parse, format = d3.time
				.format("%Y-%m-%d %H:%M"), colors = d3.scale.ordinal().range(
				[ "lightgray", "lightpink", "lightblue" ])
		// color = d3.interpolateRgb("#aad", "#556");
		// Scales. Note the inverted domain for the y-scale: bigger is up!
		var x = d3.time.scale().range([ 0, w ]), y = d3.scale.linear().range(
				[ h, 0 ]), x_dom = [], x_dom_zoom = [];

		// Axes.
		var xAxis = d3.svg.axis().scale(x).orient("bottom"), yAxis = d3.svg
				.axis().scale(y).orient("left");

		// The area generator.
		var area = d3.svg.area().x(function(d) {
			return x(d.x)
		}).y0(function(d) {
			return y(d.y0)
		}).y1(function(d) {
			return y(d.y0 + d.y)
		});

		var svg = d3.select("#chart").append("svg:svg").attr("width",
				w + m[1] + m[3]).attr("height", h + m[0] + m[2])
				.append("svg:g").attr("transform",
						"translate(" + m[3] + "," + m[0] + ")");

		svg.append("svg:rect").attr("width", w).attr("height", h);

		svg.append("svg:clipPath").attr("id", "clip").append("svg:rect").attr(
				"x", x(0)).attr("y", y(1)).attr("width", x(1) - x(0)).attr(
				"height", y(0) - y(1));

		d3.csv("stackedLayoutWithTimeAxis.csv",
				function(data) {
					// get header names
					var header_row = d3.keys(data[0])
					var gen_names = header_row.filter(function(s) {
						return s.substring(0, 7) == 'power: '
					}).map(function(s) {
						return s.substring(7, s.length)
					});
					d3.select("#footer .legend").html(
							gen_names.map(
									function(name, i) {
										return '<span style="color:'
												+ colors(i) + '">' + name
												+ '</span>'
									}).join(", "));

					console.log(colors(0))
					// Parse times and power for generators.
					var stack_gens = d3.layout.stack()(
							gen_names.map(function(gen_kind) {
								return data.map(function(d) {
									return {
										x : parse(d.times),
										y : +d['power: ' + gen_kind]
									};
								});
							}));
					// console.log(stack_gens)
					index_last_gen = stack_gens.length - 1
					index_last_time = stack_gens[0].length - 1
					// Compute the minimum and maximum date, and the maximum price.
					// d0 = stack_gens[0].map(function(d){return d.x}); //the whole domain
					x_dom = [ stack_gens[0][0].x,
							stack_gens[0][index_last_time].x ]
					d3.select("#footer .times").text(
							x_dom.map(format).join(" to "));

					x_dom_zoom = [ new Date(2010, 4 - 1, 28, 20),
							new Date(2010, 4 - 1, 29, 0) ]; //just a small part of domain
					y_dom = [ 0,
							d3.max(stack_gens[index_last_gen], function(d) {
								return d.y0 + d.y;
							}) ]

					x.domain(x_dom);
					y.domain(y_dom);

					svg.append("svg:g").attr("class", "x grid").attr(
							"transform", "translate(0," + h + ")").call(
							xAxis.tickSubdivide(0).tickSize(-h));

					svg.append("svg:g").attr("class", "y grid").attr(
							"transform", "translate(0,0)").call(
							yAxis.tickSubdivide(1).tickSize(-w));

					svg.append("svg:g").attr("class", "x axis").attr(
							"transform", "translate(0," + h + ")").call(
							xAxis.tickSubdivide(0).tickSize(6));

					svg.append("svg:g").attr("class", "y axis").call(
							yAxis.tickSubdivide(0).tickSize(6));

					svg.selectAll("g.generator").data(stack_gens).enter()
							.append("svg:path").attr("class", "generator")
							.style("fill", function(d, i) {
								return colors(i)
							}).style("stroke", function(d, i) {
								return d3.rgb(colors(i)).darker()
							}).attr("clip-path", "url(#clip)").attr("d", area)

				});

		// On click, update the x-axis.
		svg.on("click", function() {
			var new_dom = x.domain()[0] - x_dom[0] ? x_dom : x_dom_zoom;
			x.domain(new_dom);
			d3.select("#footer .times").text(new_dom.map(format).join(" to "));
			var t = svg.transition().duration(d3.event.altKey ? 7500 : 750);
			t.select("g.x.grid").call(xAxis.tickSubdivide(1).tickSize(-h));
			t.select("g.y.grid").call(yAxis.tickSubdivide(1).tickSize(-w));
			t.select("g.x.axis").call(xAxis.tickSubdivide(0).tickSize(6));
			t.select("g.y.axis").call(yAxis.tickSubdivide(0).tickSize(6));
			t.selectAll("path.generator").attr("d", area);
		});
	</script>
</body>
</html>