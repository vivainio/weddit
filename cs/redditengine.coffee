root = window

EventDispatcher = $({})

logg = ->

class RLink extends Backbone.Model
    defaults:
        linkdesc: "no description"

class RCat extends Backbone.Model
    defaults:
        name: "funny"


class RTopicGroup extends Backbone.Model
    defaults:
        groupName: "mygroup"
        topics: ["pics", "funny"]

class RTopicGroupList extends Backbone.Collection
    model: RTopicGroup
    
class RTopicGroupView extends Backbone.View
    el: "#topic-group-area"
    
    initialize: ->
        pat = $("#topic-group-template").html()
        @template = Handlebars.compile pat        
        @tglist = new RTopicGroupList
        
    render: ->
        @$el.empty()
        
        @tglist.each (m) =>
            rend = @template
                tgname: m.get "groupName"
                topics: m.get "topics"
                tgid: m.cid
                
            logg "Rendered",rend
            @$el.append rend
            
    addTg: (name, topics) ->
        m = new Backbone.Model groupName: name, topics: topics
        @tglist.add m

    doSelectGroup: (ev) ->
        
        cid = $(ev.target).data("cid")
        m = @tglist.getByCid cid
        
        
        EventDispatcher.trigger "selectCategories", [m.get "topics"]
        
    events: 
        "click .tg-name" : "doSelectGroup"        
    

class RLinkList extends Backbone.Collection
    model: RLink
    
class RCatList extends Backbone.Collection
    model: RCat
    
class RCatListView extends Backbone.View

    el: "#catlist-container"
    
    initialize:  ->                
        _.bindAll @        
        @categories_coll = new RCatList
        pat = $("#catlist-template").html()
        @catlisttmpl = Handlebars.compile pat
        @singlecatviews = {}
        
            
        
    render: ->
        @$el.empty()
        
        all = $('<div class="gen-cat-list-container">')
        @categories_coll.each (m) =>            
            
            name = m.get "name"
            rendered = @catlisttmpl
                catname: name
             
            appended = $(rendered).appendTo(all)
            
            r = appended.find(".catlist-links")
            
            #if name in @singlecatviews
            #    @singlecatviews[name].el = r
            #else
            nv = new RCatView el: r
            @singlecatviews[name] = nv
            
    
        #console.log ["catlistview render", all]
        
        @$el.append(all)
        
    
    setCategories: (cats)->        
        @categories_coll.reset ({name} for name in cats)
    
    addCategory: (name) ->
        m = new RCat
        m.set "name": name
        @categories_coll.add m
    
    getView: (name) -> @singlecatviews[name]
        
    categories: -> @categories_coll
        
    
    
class RCatView extends Backbone.View
    
    events:
        "click .linkcontainer"  : "doSelect"
        
        
        
    doSelect: (ev) ->
        
        cid = $(ev.currentTarget).data("cid")
        console.log ev, cid
        m = @coll.getByCid cid
        console.log m
        url = m.get "url"
        window.open url
        
    initialize: ->
        @coll = new RLinkList
        _.bindAll @
        pat = $("#link-template").html()
        @linktmpl = Handlebars.compile pat
        
        
    renderOne: (m) ->    
        expanded = @linktmpl
        
            linkdesc: m.get "title"
            linkscore: m.get "score"
            linkimg: m.get "thumbnail"
            cid: m.cid
            
        expanded
    
    render: ->
        all = $("<div>")
        @coll.each (m) =>
            all.append $(@renderOne(m))
                
        
        @$el.empty()
        @$el.append all

    mkModel: (d) ->
        m = new RLink
        m.set d
        #console.log m
        m
        
    addLink: (d) ->
        m = @mkModel d
        @coll.add m


class RedditEngine    
    initialize: ->        
        #@linktmpl = _.template pat
        #console.log "template", @linktmpl
        @cats = []
        @linkviews = {}
        #@mkView "pics"
        #@mkView "funny"
        
        @tgview = tg = new RTopicGroupView
        tg.addTg "Funny stuff", ["pics", "fffffffuuuuuuuuuuuu"]
        tg.addTg "Programming", ["javascript", "html5", "coffeescript"]
        
        @tgview.render()
        
        
        @mainview = mv = new RCatListView
        #mv.setCategories ["pics", "javascript"]
        #@mainview.addCategory("pics")
        #@mainview.addCategory("funny")
        #@mainview.render()

        EventDispatcher.bind "selectCategories", (ev, cats) =>            
            mv.setCategories (cats)
            mv.render()
            @fetchAll()
        
        
    fetchAll: ->
        
        @mainview.categories().each (m) => @fetchLinks m.get "name",""
            
    fetchLinks: (cat, qargs) ->        
        selector = ""
        qargs = qargs = "jsonp=?&"
        url = "http://www.reddit.com/r/#{cat}/#{selector}.json?#{qargs} "

        
        lv = @mainview.getView(cat)
        $.ajax
            url: url
            jsonp: "jsonp"
            dataType: "jsonp"
            success: (resp) =>
                items = resp.data.children
                #all = $("<div>")
                for it in items
                    d = it.data
                    
                    lv.addLink d
                    #all.append(expanded)
                    
                #console.log items
                lv.render()
                
        """        
        $.getJSON url, (resp) =>
            items = resp.data.children
            for it in items
                console.log it
        """       

root.RedditEngine = RedditEngine    
    
reng = null
    
$ ->
    logg "starting up"
    root.redditengine = reng = new RedditEngine()
    reng.initialize()
    reng.fetchAll()        
