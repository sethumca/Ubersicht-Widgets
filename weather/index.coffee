refreshFrequency: 60000

style: """
  bottom: 15%
  left: 50%
  margin: 0 0 0 -100px
  font-family: Berlin, Helvetica Neue
  color: #fff

  @font-face
    font-family Weather
    src url(weather/icons.svg) format('svg')

  .icon
    font-family: Weather
    font-size: 40px
    text-anchor: middle
    alignment-baseline: middle

  .temp
    font-size: 20px
    text-anchor: middle
    alignment-baseline: baseline

  .outline
    fill: none
    stroke: #fff
    stroke-width: 0.5

  .icon-bg
    fill: rgba(#fff, 0.95)

  .summary
    text-align: center
    border-top: 1px solid #fff
    padding: 12px 0 0 0
    margin-top: -20px
    font-size: 14px
    max-width: 200px
    line-height: 1.4

  .date, .location
    fill: #fff
    stroke: #fff
    stroke-width: 1px
    font-size: 12px
    text-anchor: middle

  .date
    fill: #ccc
    stroke: #ccc

  .date.mask
    stroke: #999
    stroke-width: 5px
"""

command: "curl -s 'https://wttr.in/Chennai?format=j1'"

render: (o) -> """
  <svg #{@svgNs} width="200px" height="200px" >
    <defs xmlns="http://www.w3.org/2000/svg">
      <mask id="icon_mask">
        <rect width="100px" height="100px" x="50" y="50" fill="#fff"
              transform="rotate(45 100 100)"/>
        <text class="icon"
              x="50%" y='45%'></text>

        <text class="temp"
              x="50%" y='65%' dx='3px'></text>
      </mask>
      <mask id="text_mask">
        <rect x='0' y="0" width="200px" height="200px" fill='#fff'/>
        <text class="location mask"
            textLength='90px'
            transform="rotate(-45 100 100)"
            x="50%" y='42px'></text>
        <text class="date mask"
            textLength='90px'
            transform="rotate(45 100 100)"
            x="50%" y='42px'></text>
      </mask>
    </defs>

    <g mask="url(#text_mask)">
      <rect class='outline' width="100px" height="100px" x="50" y="50"/>
      <rect class='outline' width="100px" height="100px" x="50" y="50"
            transform="rotate(21 100 100)"/>
      <rect class='outline' width="100px" height="100px" x="50" y="50"
            transform="rotate(66 100 100)"/>
    </g>

    <rect class='icon-bg' width="200px" height="200px" x="0" y="0"

          mask="url(#icon_mask)"/>

    <text class="location"
          textLength='90px'
          transform="rotate(-45 100 100)"
          x="50%" y='42px'></text>
    <text class="date"
          textLength='90px'
          transform="rotate(45 100 100)"
          x="50%" y='42px'></text>
  </svg>
  <div class='summary'></div>
"""

svgNs: 'xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"'

afterRender: (domEl) ->
  $(domEl).find('.location').prop('textContent', 'Chennai')
  @refresh()

update: (output, domEl) ->
  try
    data  = JSON.parse(output)
  catch e
    return

  current = data.current_condition?[0]
  return unless current

  temp = current.temp_C
  desc = current.weatherDesc?[0]?.value
  
  # For date, just use current date since it's "current" weather
  now = new Date()
  
  $(domEl).find('.temp').prop 'textContent', Math.round(temp)+'°'
  $(domEl).find('.summary').text desc
  $(domEl).find('.icon')[0]?.textContent = @getIcon(desc)
  $(domEl).find('.date').prop('textContent', @dayMapping[now.getDay()])

dayMapping:
  0: 'Sunday'
  1: 'Monday'
  2: 'Tuesday'
  3: 'Wednesday'
  4: 'Thursday'
  5: 'Friday'
  6: 'Saturday'

iconMapping:
  "rain"                :"\uf019"
  "snow"                :"\uf01b"
  "fog"                 :"\uf014"
  "cloudy"              :"\uf013"
  "wind"                :"\uf021"
  "clear-day"           :"\uf00d"
  "mostly-clear-day"    :"\uf00c"
  "partly-cloudy-day"   :"\uf002"
  "clear-night"         :"\uf02e"
  "partly-cloudy-night" :"\uf031"
  "unknown"             :"\uf03e"

getIcon: (desc) ->
  return @iconMapping['unknown'] unless desc
  desc = desc.toLowerCase()

  if desc.indexOf('sun') > -1 or desc.indexOf('clear') > -1
    return @iconMapping['clear-day']
  else if desc.indexOf('cloud') > -1 or desc.indexOf('overcast') > -1
    if desc.indexOf('partly') > -1
       return @iconMapping['partly-cloudy-day']
    else
       return @iconMapping['cloudy']
  else if desc.indexOf('rain') > -1 or desc.indexOf('drizzle') > -1 or desc.indexOf('shower') > -1
    return @iconMapping['rain']
  else if desc.indexOf('snow') > -1 or desc.indexOf('ice') > -1
     return @iconMapping['snow']
  else if desc.indexOf('fog') > -1 or desc.indexOf('mist') > -1
     return @iconMapping['fog']
  else if desc.indexOf('wind') > -1
     return @iconMapping['wind']
  
  return @iconMapping['unknown']

