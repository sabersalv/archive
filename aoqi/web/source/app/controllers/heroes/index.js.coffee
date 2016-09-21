App.HeroesIndexController = Ember.ArrayController.extend
  order_at: "name"
  order: "DESC"
  query: {}
  currentFilter: "all"
  sortProperties: ['hp']
  sortAscending: false

  maxHP: (->
    data = App.Hero.maximum[@get("currentFilter")] || {}
    data["hp"]
  ).property("currentFilter")

  maxNormalDamage: (->
    data = App.Hero.maximum[@get("currentFilter")] || {}
    data["normal_damage"]
  ).property("currentFilter")

  maxNormalArmor: (->
    data = App.Hero.maximum[@get("currentFilter")] || {}
    data["normal_armor"]
  ).property("currentFilter")

  maxMagicalDamage: (->
    data = App.Hero.maximum[@get("currentFilter")] || {}
    data["magical_damage"]
  ).property("currentFilter")

  maxMagicalArmor: (->
    data = App.Hero.maximum[@get("currentFilter")] || {}
    data["magical_armor"]
  ).property("currentFilter")

  maxSuperDamage: (->
    data = App.Hero.maximum[@get("currentFilter")] || {}
    data["super_damage"]
  ).property("currentFilter")

  maxSuperArmor: (->
    data = App.Hero.maximum[@get("currentFilter")] || {}
    data["super_armor"]
  ).property("currentFilter")

  maxSpeed: (->
    data = App.Hero.maximum[@get("currentFilter")] || {}
    data["speed"]
  ).property("currentFilter")

  cmpHP: (->
    @get("curHP") - @get("maxHP")
  ).property("curHP", "maxHP")

  cmpNormalDamage: (->
    @get("curNormalDamage") - @get("maxNormalDamage")
  ).property("curNormalDamage", "maxNormalDamage")

  cmpNormalArmor: (->
    @get("curNormalArmor") - @get("maxNormalArmor")
  ).property("curNormalArmor", "maxNormalArmor")

  cmpMagicalDamage: (->
    @get("curMagicalDamage") - @get("maxMagicalDamage")
  ).property("curMagicalDamage", "maxMagicalDamage")

  cmpMagicalArmor: (->
    @get("curMagicalArmor") - @get("maxMagicalArmor")
  ).property("curMagicalArmor", "maxMagicalArmor")

  cmpSuperDamage: (->
    @get("curSuperDamage") - @get("maxSuperDamage")
  ).property("curSuperDamage", "maxSuperDamage")

  cmpSuperArmor: (->
    @get("curSuperArmor") - @get("maxSuperArmor")
  ).property("curSuperArmor", "maxSuperArmor")

  cmpSpeed: (->
    @get("curSpeed") - @get("maxSpeed")
  ).property("curSpeed", "maxSpeed")

  selectHero: (r) ->
    @set "curHP", r.get("hp")
    @set "curNormalDamage", r.get("normalDamage")
    @set "curNormalArmor", r.get("normalArmor")
    @set "curMagicalDamage", r.get("magicalDamage")
    @set "curMagicalArmor", r.get("magicalArmor")
    @set "curSuperDamage", r.get("superDamage")
    @set "curSuperArmor", r.get("superArmor")
    @set "curSpeed", r.get("speed")

  filter: (k, v) ->
    [data, currentFilter] = [@get("data"), @get("currentFilter")]

    if currentFilter == v
      return

    if v == "all"
      content = data
    else
      content = data.filterProperty(k, v)
    @set "content", content
    @set "currentFilter", v

    # set "active" class
    $(".filter li").removeClass("active")
    $(".filter li.#{v}").addClass("active")

  sort: (name) ->
    if @get("sortProperties")[0] == name
      @set "sortAscending", not @get("sortAscending")
    else
      @set "sortProperties", [name]
      @set "sortAscending", false
