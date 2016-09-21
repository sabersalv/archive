App.Router.map ->
  @resource "heroes", ->
  @resource "attrs", ->
    @route "show", path: ":attr_id"

App.IndexRoute = Ember.Route.extend
  activate: ->
    $(document).attr "title", "奥奇传说"

App.HeroesRoute = Ember.Route.extend
  activate: ->
    $(document).attr "title", "精灵大全"

App.HeroesIndexRoute = Ember.Route.extend
  beforeModel: ->
    @types = App.Type.find()
    @attrs = App.Attr.find()

  model: ->
    App.Hero.find()

  setupController: (controller, model) ->
    controller.set "model", model
    controller.set "data", model
    controller.set "types", @types
    controller.set "attrs", @attrs

App.AttrsRoute = Ember.Route.extend
  activate: ->
    $(document).attr "title", "属性相克"

  model: ->
    App.Attr.find()
