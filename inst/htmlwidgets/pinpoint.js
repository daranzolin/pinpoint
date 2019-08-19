HTMLWidgets.widget({

  name: 'pinpoint',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(opts) {

        let data = HTMLWidgets.dataframeToD3(opts.data);
        console.log(data);

        const svg = d3.select(el)
                    .append("svg")
                    .style("width", "100%")
                    .style("height", "100%");

        let roundNumber = d3.format(".2f");
        let formatPercent = d3.format(".0%");
        let defined_fill = opts.hasOwnProperty("unique_cats");
        let centerx = opts.mark_intercept;
        let margin = ({top: 30, right: 75, bottom: 40, left: 75});
        let diffLine;
        let line_dash_value = opts.hasOwnProperty("line_type") ? opts.line_type : "dashed";
        let n_ticks = opts.hasOwnProperty("ticks") ? opts.ticks : 8;
        line_dash_value = line_dash_value === "solid" ? "0" : "8 5";
        let diffText;
        let default_fill_colors = ["#1f77b4","#ff7f0e","#2ca02c","#d62728","#9467bd","#8c564b","#e377c2","#7f7f7f","#bcbd22","#17becf"];
        let jitter_width = opts.hasOwnProperty('jitter_width') ? opts.jitter_width : 0;
        let point_radius = opts.hasOwnProperty('point_radius') ? opts.point_radius : 10;
        let fill_colors = opts.hasOwnProperty('fill_colors') ? opts.fill_colors : default_fill_colors;
        let compare_mark_color = opts.hasOwnProperty('compare_mark_color') ? opts.compare_mark_color : "black";
        let greater_than_color = opts.hasOwnProperty('greater_than_color') ? opts.greater_than_color : "forestgreen";
        let less_than_color = opts.hasOwnProperty('less_than_color') ? opts.less_than_color : "firebrick";
        let number_format = opts.hasOwnProperty("number_format") ?  d3.format(`${opts.number_format}`) : d3.format(".4");
        let draw_line_duration = opts.hasOwnProperty("draw_line_duration") ? opts.draw_line_duration : 800;
        let draw_quantiles = opts.hasOwnProperty("quantiles");
        let draw_deviations = opts.hasOwnProperty("deviations");
        let circles;
        let xdomain = d3.extent(data, d => d.x);

        if (opts.hasOwnProperty("axis_range")) {
          xdomain = opts.axis_range;
          data = data.filter(d => d.x > opts.axis_range[0] & d.x < opts.axis_range[1]);
        }

        let x = d3.scaleLinear()
            .domain(xdomain)
            .range([margin.left, width - margin.right]);

        let xAxis = g => g
            .attr("transform", `translate(0,${height-margin.bottom})`)
            .style("font-size", "16px")
            .call(d3.axisBottom(x)
                  .ticks(n_ticks)
                  .tickSizeOuter(0)
                  .tickFormat(d3.format(number_format)));

        let x2 = d3.scaleLinear()
              .domain([margin.left, width - margin.right])
              .range(xdomain);

        titleText = svg.append("text")
                .style("font-size", "20px")
                .attr("font-weight", "bold")
                .attr("id", "titleText")
                .attr("text-anchor", "middle")
                .attr("x", width/2)
                .attr("y", margin.top)
                .text(opts.title);

        let tip = d3.tip()
              .attr('class', 'd3-tipV')
              .offset([-20, 0])
              .html(function(d) {
                return `<span>${d.tooltip}</span>`;
              });

        svg.call(tip);

        if (draw_quantiles) {
          let quantiles = opts.quantiles;
          for (let i = 0; i < quantiles.length; i++) {
            console.log(quantiles[i]);
              svg.append("line")
                .attr("x1", x(quantiles[i]))
                .attr("y1", height - margin.bottom)
                .attr("x2", x(quantiles[i]))
                .attr("y2", margin.top + 100)
                .style("stroke", opts.quantile_line_color);
          }
        }
        if (draw_deviations) {
          let deviations = opts.deviations;
          console.log(deviations);
          console.log(deviations.length);
          for (let i = 0; i < deviations.length; i++) {
            console.log(deviations[i]);
              svg.append("line")
                .attr("x1", x(deviations[i]))
                .attr("y1", height - margin.bottom)
                .attr("x2", x(deviations[i]))
                .attr("y2", margin.top + 100)
                .style("stroke", opts.deviations_line_color);
          }
        }
        if (defined_fill) {

            z = d3.scaleOrdinal()
              .domain(data.map(d => d.fill))
              .range(fill_colors);

            svg.selectAll("mydots")
                .data(opts.unique_cats)
                .enter()
                .append("circle")
                  .attr("cx", margin.left)
                  .attr("cy", (d,i) => { return 50 + i*25})
                  .attr("r", point_radius)
                  .attr("fill", d => z(d));

            svg.selectAll("mylabels")
                .data(opts.unique_cats)
                .enter()
                .append("text")
                  .attr("x", margin.left + 20)
                  .attr("y", (d,i) => { return 50 + i*25})
                  .style("fill", d => z(d))
                  .text(d => d)
                  .attr("text-anchor", "left")
                  .style("alignment-baseline", "middle");

            circles = svg.append("g")
            .selectAll("circle")
            .data(data)
            .enter().append("circle")
              .attr("cx", d => x(d.x))
              .attr("cy", (d, i) => ((height - margin.bottom) - 15) - Math.random() * jitter_width)
              .attr("r", point_radius)
              .attr("opacity", 0.8)
              .attr("fill", d => z(d.fill));

        } else {

            circles = svg.append("g")
              .selectAll("circle")
              .data(data)
              .enter().append("circle")
                .attr("cx", d => x(d.x))
                .attr("cy", (d, i) => ((height - margin.bottom) - 15) - Math.random() * jitter_width)
                .attr("r", point_radius)
                .attr("opacity", 0.8)
                .attr("fill", opts.fill_color);
        }

        circles.on("mouseover", function(d) {

            tip.show(d);

            svg.append("g")
              .append("line")
              .attr("class", "diffLine")
              .attr("id", "centerXLine")
              .attr("x1", x(centerx))
              .attr("y1", height - margin.bottom)
              .attr("x2", x(centerx))
              .attr("y2", margin.top + 40)
              .attr("stroke", compare_mark_color)
              .attr("stroke-width", 3);

            circles.attr("opacity", 0.20);
            let p = d3.select(this);

            p.attr("opacity", 1)
              .attr("stroke", "black")
              .attr("stroke-width", 2)
              .transition()
              .attr("r", point_radius * 1.6);

            let thisValue = x2(+p.attr("cx"));
            let diffValue = thisValue - centerx;

            diffLine = svg.append("line")
              .attr("class", "diffLine")
              .attr("id", "diffLineX")
              .attr("x1", p.attr("cx"))
              .attr("y1", p.attr("cy"))
              .attr("x2", p.attr("cx"))
              .attr("y2", p.attr("cy"))
              .attr("stroke", diffValue < 0 ? less_than_color : greater_than_color)
              .attr("stroke-dasharray", line_dash_value)
              .attr("stroke-width", 1.1)
              .transition()
              .duration(draw_line_duration)
              .attr("x2", x(centerx))
              .attr("y2", p.attr("cy"));

            diffText = svg.append("text")
                .style("font-size", "18px")
                .attr("font-weight", "bold")
                .style("fill", diffValue < 0 ? less_than_color : greater_than_color)
                .attr("id", "diffValueText")
                .attr("text-anchor", "middle")
                .attr("x", x((thisValue + centerx) / 2))
                .attr("y", p.attr("cy") - 10)
                .text(d3.format(`${number_format}`)(diffValue));
            })
            .on("mouseout", function(d) {
              tip.hide(d);
              d3.select(this).attr("r", point_radius).attr("stroke-width", 0);
              circles.attr("opacity", 1);
              svg.select("#diffValueText").remove();
              svg.select("#diffLineX").remove();
              svg.select("#centerXLine").remove();
            });

            svg.append("g").call(xAxis);
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
