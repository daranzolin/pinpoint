HTMLWidgets.widget({

  name: 'comparePoints',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(opts) {

        const data = HTMLWidgets.dataframeToD3(opts.data);
        //console.log(data);
        const svg = d3.select(el)
                    .append("svg")
                    .style("width", "100%")
                    .style("height", "100%");

        let roundNumber = d3.format(".2f");
        let formatPercent = d3.format(".0%");
        let defined_fill = opts.hasOwnProperty("unique_cats");
        let centerx = opts.mark_intercept;
        let radius = 10;
        let margin = ({top: 20, right: 20, bottom: 50, left: 40});
        let diffLine;
        let diffText;
        let jitter_width = opts.hasOwnProperty('jitter_width') ? opts.jitter_width : 0;
        let number_format = opts.hasOwnProperty("number_format") ?  d3.format(`${opts.number_format}`) : d3.format(".4");
        let circles;

        let x = d3.scaleLinear()
            .domain(d3.extent(data, d => d.x))
            .range([margin.left, width - margin.right]);

        let xAxis = g => g
            .attr("transform", `translate(0,${height-margin.bottom})`)
            .style("font-size", "16px")
            .call(d3.axisBottom(x)
                  .ticks(8)
                  .tickSizeOuter(0)
                  .tickFormat(d3.format(number_format)));

        let x2 = d3.scaleLinear()
              .domain([margin.left, width - margin.right])
              .range(d3.extent(data, d => d.x));

        titleText = svg.append("text")
                .style("font-size", "20px")
                .attr("font-weight", "bold")
                .attr("id", "titleText")
                .attr("text-anchor", "middle")
                .attr("x", width/2)
                .attr("y", margin.top)
                .text(opts.title);

        if (defined_fill) {

            z = d3.scaleOrdinal()
              .domain(data.map(d => d.fill))
              .range(d3.schemeCategory10);

            svg.selectAll("mydots")
                .data(opts.unique_cats)
                .enter()
                .append("circle")
                  .attr("cx", margin.left)
                  .attr("cy", (d,i) => { return 100 + i*25})
                  .attr("r", radius)
                  .attr("fill", d => z(d));

            svg.selectAll("mylabels")
                .data(opts.unique_cats)
                .enter()
                .append("text")
                  .attr("x", margin.left + 20)
                  .attr("y", (d,i) => { return 100 + i*25})
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
              .attr("r", radius)
              .attr("opacity", 0.8)
              .attr("fill", d => z(d.fill));

        } else {

            circles = svg.append("g")
              .selectAll("circle")
              .data(data)
              .enter().append("circle")
                .attr("cx", d => x(d.x))
                .attr("cy", (d, i) => ((height - margin.bottom) - 15) - Math.random() * jitter_width)
                .attr("r", radius)
                .attr("opacity", 0.8)
                .attr("fill", opts.fill_color);
        }


        circles.on("mouseover", function() {

            svg.append("g")
              .append("line")
              .attr("class", "diffLine")
              .attr("id", "centerXLine")
              .attr("x1", x(centerx))
              .attr("y1", height - margin.bottom)
              .attr("x2", x(centerx))
              .attr("y2", margin.top + 10)
              .attr("stroke", "#E8BF6A")
              .attr("stroke-width", 3);

            circles.attr("opacity", 0.20);
            let p = d3.select(this);

            p.attr("opacity", 1)
              .attr("stroke", "black")
              .attr("stroke-width", 2)
              .transition()
              .attr("r", radius * 1.6);

            let thisValue = x2(+p.attr("cx"));
            let diffValue = thisValue - centerx;

            diffLine = svg.append("line")
              .attr("class", "diffLine")
              .attr("id", "diffLineX")
              .attr("x1", p.attr("cx"))
              .attr("y1", p.attr("cy"))
              .attr("x2", p.attr("cx"))
              .attr("y2", p.attr("cy"))
              .attr("stroke", diffValue < 0 ? "firebrick" : "forestgreen")
              .attr("stroke-width", 0.75)
              .transition()
              .duration(800)
              .attr("x2", x(centerx))
              .attr("y2", p.attr("cy"));

            diffText = svg.append("text")
                .style("font-size", "18px")
                .attr("font-weight", "bold")
                .style("fill", diffValue < 0 ? "firebrick" : "forestgreen")
                .attr("id", "diffValueText")
                .attr("text-anchor", "middle")
                .attr("x", x((thisValue + centerx) / 2))
                .attr("y", p.attr("cy") - 10)
                .text(d3.format(`${number_format}`)(diffValue));
            })
            .on("mouseout", function() {
              d3.select(this).attr("r", radius).attr("stroke-width", 0);
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
