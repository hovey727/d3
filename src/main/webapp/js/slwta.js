var m = [ 79, 80, 160, 79 ], w = 1000 - m[1] - m[3], h = 500 - m[0]
				- m[2], parse = d3.time.format("%Y-%m-%d %H:%M:%S").parse, format = d3.time
				.format("%Y-%m-%d %H:%M"), colors = d3.scale.ordinal().range(
				[ "lightgreen", "lightpink", "lightblue", "lightgray" ])
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