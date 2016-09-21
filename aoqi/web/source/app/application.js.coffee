#= require jquery
#= require handlebars
#= require ember
#= require ember-data
#= require pd
#= require bootstrap
#= require ./main

$.ajax "#{API_URL}/heroes/maximum", async: false, success: (data) ->
  App.Hero.maximum = data
