// Generated by CoffeeScript 1.3.3
(function() {
  var App, EventDispatcher, RCat, RCatList, RCatListView, RCatView, RLink, RLinkList, RTopicGroup, RTopicGroupList, RTopicGroupView, RedditEngine, VGroupEditor, VManageGroups, app, collectionToJson, logg, reng, root,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  root = window;

  App = (function() {

    function App() {}

    App.prototype.start = function() {
      var ge, mg, mv, reng, tg,
        _this = this;
      this.topicGroups = new RTopicGroupList;
      this.topicGroups.fetch();
      this.shownCategories = new RCatList;
      root.redditengine = reng = new RedditEngine();
      this.tgview = tg = new RTopicGroupView;
      this.tgview.render();
      this.mainview = mv = new RCatListView;
      this.vManageGroups = mg = new VManageGroups;
      mg.render();
      this.vGroupEditor = ge = new VGroupEditor;
      EventDispatcher.bind("selectCategories", function(ev, cats) {
        console.log(cats);
        mv.setCategories(cats);
        mv.render();
        return reng.fetchAll();
      });
      reng.initialize();
      return reng.fetchAll();
    };

    return App;

  })();

  EventDispatcher = $({});

  app = new App();

  logg = function() {
    return 1;
  };

  collectionToJson = function(coll) {
    return coll.map(function(m) {
      var o;
      o = m.toJSON();
      o.cid = m.cid;
      return o;
    });
  };

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

    RTopicGroupList.prototype.localStorage = new Store("topicgroups");

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
      var pat,
        _this = this;
      pat = $("#topic-group-template").html();
      this.template = Handlebars.compile(pat);
      this.tglist = app.topicGroups;
      return this.tglist.bind("change", function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        console.log("Changed!", args);
        return _this.render();
      });
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
      return this.tglist.create({
        groupName: name,
        topics: topics
      });
    };

    RTopicGroupView.prototype.makeCurrent = function(elem) {
      $(".tg-current-choice").removeClass("tg-current-choice");
      return elem.addClass("tg-current-choice");
    };

    RTopicGroupView.prototype.doSelectGroup = function(ev) {
      var cid, m, trg;
      trg = $(ev.target);
      cid = trg.data("cid");
      this.makeCurrent(trg);
      m = this.tglist.getByCid(cid);
      return EventDispatcher.trigger("selectCategories", [m.get("topics")]);
    };

    RTopicGroupView.prototype.doSelectTopic = function(ev) {
      var topic, trg;
      trg = $(ev.target);
      this.makeCurrent(trg);
      topic = trg.text();
      console.log("topic", topic);
      return EventDispatcher.trigger("selectCategories", [[topic]]);
    };

    RTopicGroupView.prototype.events = {
      "click .tg-name": "doSelectGroup",
      "click .tg-topic": "doSelectTopic"
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
      app.shownCategories.each(function(m) {
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
      return app.shownCategories.reset((function() {
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
      return app.shownCategories.add(m);
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
      "click .linkcontainer": "doSelect",
      "click .rightedge": "doSelectComments"
    };

    RCatView.prototype.modelByCid = function(cid) {
      return this.coll.getByCid(cid);
    };

    RCatView.prototype.openWindow = function(url) {
      return window.open(url);
    };

    RCatView.prototype.doSelect = function(ev) {
      var cid, m, url;
      cid = $(ev.currentTarget).data("cid");
      m = this.modelByCid(cid);
      url = m.get("url");
      return this.openWindow(url);
    };

    RCatView.prototype.doSelectComments = function(ev) {
      var cid, fullurl, m, plink;
      cid = $(ev.currentTarget).parent().data("cid");
      m = this.modelByCid(cid);
      plink = m.get("permalink");
      console.log(["comments!", m, m.get("permalink")]);
      fullurl = "http://reddit.com" + plink + ".compact";
      this.openWindow(fullurl);
      return ev.stopPropagation();
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
        linkcomments: m.get("num_comments"),
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

  VManageGroups = (function(_super) {

    __extends(VManageGroups, _super);

    function VManageGroups() {
      return VManageGroups.__super__.constructor.apply(this, arguments);
    }

    VManageGroups.prototype.el = "#manage-groups-area";

    VManageGroups.prototype.events = {
      "click .topic-group-item": "doSelectGroup",
      "click #btnNewGroup": "doNewGroup"
    };

    VManageGroups.prototype.initialize = function() {
      var pat,
        _this = this;
      _.bindAll(this);
      pat = $("#manage-groups-template").text();
      this.tmplManageGroups = Handlebars.compile(pat);
      return app.topicGroups.bind("change remove", function() {
        return _this.render();
      });
    };

    VManageGroups.prototype.render = function() {
      var context, h;
      context = {
        groups: collectionToJson(app.topicGroups)
      };
      console.log(context);
      h = this.tmplManageGroups(context);
      this.$el.html(h);
      return this.$(".rootlist").listview("refresh");
    };

    VManageGroups.prototype.modelByCid = function(cid) {
      return app.topicGroups.getByCid(cid);
    };

    VManageGroups.prototype.doSelectGroup = function(ev) {
      var m;
      m = this.modelByCid($(ev.currentTarget).data("cid"));
      return this.switchToGroupEditor(m);
    };

    VManageGroups.prototype.switchToGroupEditor = function(m) {
      var _this = this;
      app.vGroupEditor.model = m;
      app.vGroupEditor.render();
      $("#pagegroupeditor").page();
      return _.defer(function() {
        $.mobile.changePage("#pagegroupeditor");
        return app.vGroupEditor.updateList();
      });
    };

    VManageGroups.prototype.doNewGroup = function(ev) {
      var m;
      console.log("Add new group");
      m = app.topicGroups.create({
        groupName: "<untitled>",
        topics: []
      });
      this.switchToGroupEditor(m);
      return app.vGroupEditor.model = m;
    };

    return VManageGroups;

  })(Backbone.View);

  VGroupEditor = (function(_super) {

    __extends(VGroupEditor, _super);

    function VGroupEditor() {
      return VGroupEditor.__super__.constructor.apply(this, arguments);
    }

    VGroupEditor.prototype.el = "#group-editor-area";

    VGroupEditor.prototype.events = {
      "click #btnAdd": "doAddCat",
      "click .aRemoveCat": "doRemoveCat",
      "click #btnApplyChangeGroupName": "doChangeGroupName"
    };

    VGroupEditor.prototype.initialize = function() {
      var pat,
        _this = this;
      _.bindAll(this);
      pat = $("#group-editor-template").text();
      this.tmpl = Handlebars.compile(pat);
      return $("#btnDeleteGroup").on("click", function() {
        console.log("Delete group!");
        _this.model.destroy();
        return history.back();
      });
    };

    VGroupEditor.prototype.updateList = function() {
      var ul;
      ul = this.$(".rootlist");
      return ul.listview();
    };

    VGroupEditor.prototype.render = function() {
      var context, h;
      console.log("render");
      if (!this.model) {
        return;
      }
      context = this.model.toJSON();
      h = this.tmpl(context);
      return this.$el.html(h);
    };

    VGroupEditor.prototype.doAddCat = function(ev) {
      var m, t, topics;
      t = $("#inpNewCategory").val();
      console.log("add cat", t);
      if (t.length < 1) {
        return;
      }
      m = this.model;
      topics = m.get("topics");
      console.log("add to", topics);
      topics.push(t);
      m.set("topics", topics);
      m.save();
      this.render();
      return this.updateList();
    };

    VGroupEditor.prototype.doRemoveCat = function(ev) {
      var elem, m, toRemove, topics, ul;
      elem = $(ev.currentTarget);
      toRemove = elem.text();
      console.log("Remove cat", toRemove);
      ul = this.$(".rootlist");
      m = this.model;
      topics = _.without(m.get("topics"), toRemove);
      m.set("topics", topics);
      m.save();
      this.render();
      return this.updateList();
    };

    VGroupEditor.prototype.doChangeGroupName = function(ev) {
      var t;
      t = $("#inpGroupName").val();
      console.log("Change to", t);
      this.model.set("groupName", t);
      return this.model.save();
    };

    return VGroupEditor;

  })(Backbone.View);

  RedditEngine = (function() {

    function RedditEngine() {}

    RedditEngine.prototype.initialize = function() {
      this.cats = [];
      return this.linkviews = {};
    };

    RedditEngine.prototype.fetchAll = function() {
      var _this = this;
      return app.shownCategories.each(function(m) {
        return _this.fetchLinks(m.get("name", ""));
      });
    };

    RedditEngine.prototype.fetchLinks = function(cat, qargs) {
      var lv, selector, url,
        _this = this;
      selector = "";
      qargs = qargs = "jsonp=?&";
      url = "http://www.reddit.com/r/" + cat + "/" + selector + ".json?" + qargs + " ";
      lv = app.mainview.getView(cat);
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
    return app.start();
  });

}).call(this);
