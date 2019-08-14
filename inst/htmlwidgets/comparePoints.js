HTMLWidgets.widget({

  name: 'comparePoints',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(opts) {
        
        const data = HTMLWidgets.dataframeToD3(opts.data);
        console.log(data);

        const svg = d3.select(el)
                    .append("svg")
                    .style("width", "100%")
                    .style("height", "100%");
                    
        let roundNumber = d3.format(".2f");
        let formatPercent = d3.format(".0%");
        let centerx = d3.mean(data, d => d.x);
        let radius = 10;
        let margin = ({top: 20, right: 20, bottom: 50, left: 40});
        let diffLine;
        let diffText;

        let x = d3.scaleLinear()
            .domain(d3.extent(data, d => d.x))
            .range([margin.left, width - margin.right]);

        let xAxis = g => g
            .attr("transform", `translate(0,${height-margin.bottom})`)
            .style("font-size", "16px")
            .call(d3.axisBottom(x)
                  .ticks(8)
                  .tickSizeOuter(0)
                  .tickFormat(d3.format(".0%")));
          
        let x2 = d3.scaleLinear()
              .domain([margin.left, width - margin.right])
              .range(d3.extent(data, d => d.x));
 
        let y = d3.scaleBand()
              .domain(["Line 1"])
              .range([height-margin.bottom + 10]);  

        const circles = svg.append("g")
              .attr("fill", "#463077")
            .selectAll("circle")
            .data(data)
            .enter().append("circle")
              .attr("cx", d => x(d.x))
              .attr("cy", (height - margin.bottom) - 15)
              .attr("r", radius)
              .attr("opacity", 0.8);
              
        /*
        let tip = d3.tip()
              .attr('class', 'd3-tipV')
              .offset([-10, 0])
              .html(function(d) {
                return opts.tooltipHTML;
              });

        svg.call(tip); */
      
        circles.on("mouseover", function() {
      
            svg.append("g")
              .append("line")
              .attr("class", "diffLine")
              .attr("id", "centerXLine")
              .attr("x1", x(centerx))
              .attr("y1", height - margin.bottom)
              .attr("x2", x(centerx))
              .attr("y2", margin.top)
              .attr("stroke", "#E8BF6A")
              .attr("stroke-width", 3);
          
            circles.attr("opacity", 0.20);
            let p = d3.select(this);
        
            p.attr("opacity", 1)
              .transition()
              .attr("r", radius * 1.5)
              .attr("fill", "#C99700");
            
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
              .attr("y2", (height - margin.bottom) - 15);  
        
            diffText = svg.append("text")
                .style("font-size", "18px")
                .attr("font-weight", "bold")
                .style("fill", diffValue < 0 ? "firebrick" : "forestgreen")
                .attr("id", "diffValueText")
                .attr("text-anchor", "middle")
                .attr("x", x((thisValue + centerx) / 2))
                .attr("y", (height - margin.bottom) - 19)
                .text(formatPercent(roundNumber(diffValue)));
            })
            .on("mouseout", function() {
              d3.select(this).attr("r", radius).attr("fill", "#463077");
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