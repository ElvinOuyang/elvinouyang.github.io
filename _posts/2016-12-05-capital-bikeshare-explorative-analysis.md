---
layout: post
title: "Exploratory Data Analytics on Capital Bikeshare Data 2015"
date: 2016-12-05
---

### Project Introduction
In the last decade there has been increasing concern regarding the environment and the quality of life, especially in big cities. From increasing taxation to financial incentives, different approaches and public policies have been proposed and tested all around the world to address these concerns. In this scenario, shared cars and shared bicycles have became popular solutions in many cities to help mitigate traffic and environmental impact.  How can these programs be set up for success?

Due to the increasing importance and popularity of the **Capital Bikeshare program** in the District of Columbia, this project aims to:

1. Identify the variables that most impact hourly ridership
2. Develop a model to predict hourly bikeshare demand in the Greater Washington DC region based on historical ridership and weather data for 2015.

### Explorative Data Analysis and Visualization

In this report, I will focus on the explorative analysis of the capital bikeshare data for 2015. The aim of the EDA process is to generate a high-level understanding of the underlying data and identify potential relationships amongst variables. This data exploration stage then focused on visualizing these relationships and patterns to make it easier for the audience to understand.

The following sequence of commentary and code showcases the EDA that was conducted.

The first thing I'll do is to run **distribution analysis** on the main continuous variables in the dataset: _total.rides_ and _avg.duration_. We will use levels in five categorical variables, i.e. _Subscription.Type_, _weekend_holiday_, _rushhour_, _season_, and _AdverseWeather_, as grouping color to generate high level between-group distribution comparison.



![plot of chunk unnamed-chunk-6](/assets/Rfig/unnamed-chunk-6-1.svg)![plot of chunk unnamed-chunk-6](/assets/Rfig/unnamed-chunk-6-2.svg)![plot of chunk unnamed-chunk-6](/assets/Rfig/unnamed-chunk-6-3.svg)![plot of chunk unnamed-chunk-6](/assets/Rfig/unnamed-chunk-6-4.svg)![plot of chunk unnamed-chunk-6](/assets/Rfig/unnamed-chunk-6-5.svg)


My first impression is that the distribution of total.rides is skewing right, while the distribution of avg.duration has two modes.

More specifically, the avg.duration distribution by Subscription.Type graph indicates that registered bikers are contributing to the lower duration mode while the casual bikers are contributing to the higher mode. Casual bikers have much less total.rides than the registered bikers. In the distribution by rushhour graph, commuting hour rides are dominating hours that have higher count of total.rides. Rushhour rides are also contributing more to the lower avg.duration mode. Another interesting finding from the distribution by season graph is that winter has much more short-duration rides than other seasons, while spring and summer have more long-duration rides among casual riders.

The above analysis indicates that time-related factors are having a strong impact on the dependent variables. In my next step, I will create heat maps for hour of the day / day of the week to further explore the patterns.


![plot of chunk unnamed-chunk-8](/assets/Rfig/unnamed-chunk-8-1.svg)
Here I find some interesting patterns from the hour-weekday heat map. It seems that more rides have taken place during rush hours on work days, while total.rides distributes evenly in day time on weekend. The avg.duration of the rides appears to be longer during day time over the weekend.

After having a general understanding of the data, I move on to explore the geospatial distribution of total.rides across the DC metro area. First let us plot the bike stations.

{% highlight text %}
## # A tibble: 6 × 6
##                   Start.station total.rides avg.duration
##                          <fctr>       <int>        <dbl>
## 1                10th & E St NW       13611     25.61816
## 2         10th & Florida Ave NW        8316     12.16949
## 3                10th & K St NW        9895     15.84791
## 4           10th & Monroe St NE        3916     15.95705
## 5                10th & U St NW       13463     12.52403
## 6 10th St & Constitution Ave NW       19128     28.62108
## # ... with 3 more variables: subscriber.percentage <dbl>, lat <dbl>,
## #   lon <dbl>
{% endhighlight %}

Below I can see the locations of all the bike share stations across the DMV area, with the circle size representing total.rides and color representing avg.rides. It appears that bike stations are spreading out well in the DMV area, with stations located in DMV outskirts such as Alexandria, VA, Bethesda, MD, and Silver Spring, MD.


![plot of chunk unnamed-chunk-11](/assets/Rfig/unnamed-chunk-11-1.svg)![plot of chunk unnamed-chunk-11](/assets/Rfig/unnamed-chunk-11-2.svg)![plot of chunk unnamed-chunk-11](/assets/Rfig/unnamed-chunk-11-3.svg)

But how does the actual count of total.rides distribute across the area? Will it go in line with the bike station locations? I then move on to create a density map based on the density of total.rides on the map. The graph below indicates that total.rides are way more condensed than the distribution of the bike stations, with the most rides happening in the DC heart area, such as Dupont Circle, Logan Circle, National Mall, Metro Center, Gallery Place, World Bank, and Lincoln Memorial.


![plot of chunk unnamed-chunk-13](/assets/Rfig/unnamed-chunk-13-1.svg)![plot of chunk unnamed-chunk-13](/assets/Rfig/unnamed-chunk-13-2.svg)![plot of chunk unnamed-chunk-13](/assets/Rfig/unnamed-chunk-13-3.svg)

Since I now have a general idea of where the most rides are happening in DC, my next step is to slice the ridership data with factors I generated from time and weather and compare the patterns. I wanted to see if the popularity of the stations changed under different time and weather conditions.

My next step is to slice the ridership data according to factors I generated from weather and time. I wanted to see if the popularity of the stations changed under different time and weather conditions.

![plot of chunk unnamed-chunk-16](/assets/Rfig/unnamed-chunk-16-1.svg)

The first graph shows the distribution of rides in each season of the year of 2015. In Spring and Summer, both Lincoln Memorial and National Mall enjoy more rides from other time of the year. During winter, however, it seems that more people are taking bike rides around Logan Circle, Foggy Bottom, and Metro Center, i.e. the inner center of the District.

![plot of chunk unnamed-chunk-17](/assets/Rfig/unnamed-chunk-17-1.svg)

Another similar comparison based on time of the day shows that people are taking more rides in central to northeastern DC in the morning and more in central to southwestern DC in the afternoon. Bikers start their rides mostly around DuPont circle, Logan Circle, Metro Center, and Gallery Place at night. Few people will start their rides in late night, of course; but we are seeing relatively more rides in the central to northwestern DC area. It seems that people's daily routine is contributing to this pattern, considering that these areas correspond to the residence area, working area, and entertaining/event area in DC.

![plot of chunk unnamed-chunk-18](/assets/Rfig/unnamed-chunk-18-1.svg)

Since time is creating interesting impact on total.rides and bikes can be a useful tool for commuting, I want to check out specifically the allocation of rides for rush hours against other time of the day. In the above graph, we notice that more people are taking bike rides near Metro Center, Gallery Place, and Capital Hill during rush hours, while more people are taking rides near Lincoln Memorial and National Mall during non-rush hours. This information is interesting, since Metro center, Gallery place, and Capital Hill are places where many people go to work, while (apparently) Lincoln Memorial and National Mall are popular tourist sites.

![plot of chunk unnamed-chunk-19](/assets/Rfig/unnamed-chunk-19-1.svg)
Since Lincoln Memorial and National Mall are enjoying much love in non-rush hours, I am interested to check out if leisure time will have a different pattern for total.rides distribution. Comparing the left two graphs in the above chart, it is apparent that the distribution of ridership is sparse for leisure days in good weather: riders are of course starting their rides from many different stations across the District. Interestingly, the second left graph shows that bikers mostly still ride in the central DC during working days despite the good weather. Commuting really seems to be a major function of the shared bikes!

Since commuting seems to be a really big factor for the distribution of rides, I am interested to dig a bit deeper into the type of subscription for each ride. Since bike share subscribers are more likely to use bikes for commute, will I see a clear difference between casual and registered bikers?

![plot of chunk unnamed-chunk-20](/assets/Rfig/unnamed-chunk-20-1.svg)

The above graph shows that casual bikers are (apparently) taking more rides around the tourist attraction sites in DC, no matter if it's in rush hour or not. For the subscribers, however, the distribution of rides are surprisingly even no matter it's rush hour or not. If we really consider the nature of commuting, this actually makes sense: for people that ride bikes based on their daily commuting needs, they will need to use bikes to get to work or go home. The green area in the right two graphs actually shows the routine start stations for the registered users!

![plot of chunk unnamed-chunk-21](/assets/Rfig/unnamed-chunk-21-1.svg)

A quick comparison of adverse weather against non-adverse weather shows not much difference for the ridership. This might be due to the nature of our integrated weather data: the weather information is the mean values for a whole day, thus making it hard for the slicers to differentiate ridership distribution on a lower grain level.

![plot of chunk unnamed-chunk-22](/assets/Rfig/unnamed-chunk-22-1.svg)

Again, in the graph shown above here, we observe a bigger differece from Rush Hour than the weather. This seems to be related to the same challenge I was having from the weather variables.
