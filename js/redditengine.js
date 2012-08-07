// Generated by CoffeeScript 1.3.3
(function() {
  var EventDispatcher, RCat, RCatList, RCatListView, RCatView, RLink, RLinkList, RTopicGroup, RTopicGroupList, RTopicGroupView, RedditEngine, logg, reng, root,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  root = window;

  EventDispatcher = $({});

  logg = function() {};

  RLink = (function(_super) {

    __extends(RLink, _super);

    function RLink() {
      return RLink.__super__.constructor.apply(this, arguments);
    }

    RLink.prototype.defaults = {
      linkdesc: "no description"
    };

    return RLink;

  })(Backbone.Model);

  RCat = (function(_super) {

    __extends(RCat, _super);

    function RCat() {
      return RCat.__super__.constructor.apply(this, arguments);
    }

    RCat.prototype.defaults = {
      name: "funny"
    };

    return RCat;

  })(Backbone.Model);

  RTopicGroup = (function(_super) {

    __extends(RTopicGroup, _super);

    function RTopicGroup() {
      return RTopicGroup.__super__.constructor.apply(this, arguments);
    }

    RTopicGroup.prototype.defaults = {
      groupName: "mygroup",
      topics: ["pics", "funny"]
    };

    return RTopicGroup;

  })(Backbone.Model);

  RTopicGroupList = (function(_super) {

    __extends(RTopicGroupList, _super);

    function RTopicGroupList() {
      return RTopicGroupList.__super__.constructor.apply(this, arguments);
    }

    RTopicGroupList.prototype.model = RTopicGroup;

    return RTopicGroupList;

  })(Backbone.Collection);

  RTopicGroupView = (function(_super) {

    __extends(RTopicGroupView, _super);

    function RTopicGroupView() {
      return RTopicGroupView.__super__.constructor.apply(this, arguments);
    }

    RTopicGroupView.prototype.el = "#topic-group-area";

    RTopicGroupView.prototype.initialize = function() {
      var pat;
      pat = $("#topic-group-template").html();
      this.template = Handlebars.compile(pat);
      return this.tglist = new RTopicGroupList;
    };

    RTopicGroupView.prototype.render = function() {
      var _this = this;
      this.$el.empty();
      return this.tglist.each(function(m) {
        var rend;
        rend = _this.template({
          tgname: m.get("groupName"),
          topics: m.get("topics"),
          tgid: m.cid
        });
        logg("Rendered", rend);
        return _this.$el.append(rend);
      });
    };

    RTopicGroupView.prototype.addTg = function(name, topics) {
      var m;
      m = new Backbone.Model({
        groupName: name,
        topics: topics
      });
      return this.tglist.add(m);
    };

    RTopicGroupView.prototype.doSelectGroup = function(ev) {
      var cid, m;
      cid = $(ev.target).data("cid");
      m = this.tglist.getByCid(cid);
      return EventDispatcher.trigger("selectCategories", [m.get("topics")]);
    };

    RTopicGroupView.prototype.events = {
      "click .tg-name": "doSelectGroup"
    };

    return RTopicGroupView;

  })(Backbone.View);

  RLinkList = (function(_super) {

    __extends(RLinkList, _super);

    function RLinkList() {
      return RLinkList.__super__.constructor.apply(this, arguments);
    }

    RLinkList.prototype.model = RLink;

    return RLinkList;

  })(Backbone.Collection);

  RCatList = (function(_super) {

    __extends(RCatList, _super);

    function RCatList() {
      return RCatList.__super__.constructor.apply(this, arguments);
    }

    RCatList.prototype.model = RCat;

    return RCatList;

  })(Backbone.Collection);

  RCatListView = (function(_super) {

    __extends(RCatListView, _super);

    function RCatListView() {
      return RCatListView.__super__.constructor.apply(this, arguments);
    }

    RCatListView.prototype.el = "#catlist-container";

    RCatListView.prototype.initialize = function() {
      var pat;
      _.bindAll(this);
      this.categories_coll = new RCatList;
      pat = $("#catlist-template").html();
      this.catlisttmpl = Handlebars.compile(pat);
      return this.singlecatviews = {};
    };

    RCatListView.prototype.render = function() {
      var all,
        _this = this;
      this.$el.empty();
      all = $('<div class="gen-cat-list-container">');
      this.categories_coll.each(function(m) {
        var appended, name, nv, r, rendered;
        name = m.get("name");
        rendered = _this.catlisttmpl({
          catname: name
        });
        appended = $(rendered).appendTo(all);
        r = appended.find(".catlist-links");
        nv = new RCatView({
          el: r
        });
        return _this.singlecatviews[name] = nv;
      });
      return this.$el.append(all);
    };

    RCatListView.prototype.setCategories = function(cats) {
      var name;
      return this.categories_coll.reset((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = cats.length; _i < _len; _i++) {
          name = cats[_i];
          _results.push({
            name: name
          });
        }
        return _results;
      })());
    };

    RCatListView.prototype.addCategory = function(name) {
      var m;
      m = new RCat;
      m.set({
        "name": name
      });
      return this.categories_coll.add(m);
    };

    RCatListView.prototype.getView = function(name) {
      return this.singlecatviews[name];
    };

    RCatListView.prototype.categories = function() {
      return this.categories_coll;
    };

    return RCatListView;

  })(Backbone.View);

  RCatView = (function(_super) {

    __extends(RCatView, _super);

    function RCatView() {
      return RCatView.__super__.constructor.apply(this, arguments);
    }

    RCatView.prototype.events = {
      "click .linkcontainer": "doSelect"
    };

    RCatView.prototype.doSelect = function(ev) {
      var cid, m, url;
      cid = $(ev.currentTarget).data("cid");
      console.log(ev, cid);
      m = this.coll.getByCid(cid);
      console.log(m);
      url = m.get("url");
      return window.open(url);
    };

    RCatView.prototype.initialize = function() {
      var pat;
      this.coll = new RLinkList;
      _.bindAll(this);
      pat = $("#link-template").html();
      return this.linktmpl = Handlebars.compile(pat);
    };

    RCatView.prototype.renderOne = function(m) {
      var expanded;
      expanded = this.linktmpl({
        linkdesc: m.get("title"),
        linkscore: m.get("score"),
        linkimg: m.get("thumbnail"),
        cid: m.cid
      });
      return expanded;
    };

    RCatView.prototype.render = function() {
      var all,
        _this = this;
      all = $('<ul data-role="listview" data-theme="g">');
      this.coll.each(function(m) {
        return all.append($(_this.renderOne(m)));
      });
      this.$el.empty();
      this.$el.append(all);
      all.listview();
      return all.listview("refresh");
    };

    RCatView.prototype.mkModel = function(d) {
      var m;
      m = new RLink;
      m.set(d);
      return m;
    };

    RCatView.prototype.addLink = function(d) {
      var m;
      m = this.mkModel(d);
      return this.coll.add(m);
    };

    return RCatView;

  })(Backbone.View);

  RedditEngine = (function() {

    function RedditEngine() {}

    RedditEngine.prototype.initialize = function() {
      var mv, tg,
        _this = this;
      this.cats = [];
      this.linkviews = {};
      this.tgview = tg = new RTopicGroupView;
      tg.addTg("Funny stuff", ["pics", "fffffffuuuuuuuuuuuu"]);
      tg.addTg("Programming", ["javascript", "html5", "coffeescript"]);
      this.tgview.render();
      this.mainview = mv = new RCatListView;
      return EventDispatcher.bind("selectCategories", function(ev, cats) {
        mv.setCategories(cats);
        mv.render();
        return _this.fetchAll();
      });
    };

    RedditEngine.prototype.fetchAll = function() {
      var _this = this;
      return this.mainview.categories().each(function(m) {
        return _this.fetchLinks(m.get("name", ""));
      });
    };

    RedditEngine.prototype.fetchLinks = function(cat, qargs) {
      var lv, selector, url,
        _this = this;
      selector = "";
      qargs = qargs = "jsonp=?&";
      url = "http://www.reddit.com/r/" + cat + "/" + selector + ".json?" + qargs + " ";
      lv = this.mainview.getView(cat);
      $.ajax({
        url: url,
        jsonp: "jsonp",
        dataType: "jsonp",
        success: function(resp) {
          var d, it, items, _i, _len;
          items = resp.data.children;
          for (_i = 0, _len = items.length; _i < _len; _i++) {
            it = items[_i];
            d = it.data;
            lv.addLink(d);
          }
          return lv.render();
        }
      });
      return "        \n$.getJSON url, (resp) =>\n    items = resp.data.children\n    for it in items\n        console.log it";
    };

    return RedditEngine;

  })();

  root.RedditEngine = RedditEngine;

  reng = null;

  $(function() {
    logg("starting up");
    root.redditengine = reng = new RedditEngine();
    reng.initialize();
    return reng.fetchAll();
  });

}).call(this);
