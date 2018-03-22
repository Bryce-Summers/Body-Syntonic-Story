// Generated by CoffeeScript 1.11.1

/*
    Written by Bryce Summers on 10.23.2017

    Objects are agents that try to do stuff. They carry along data, then sleep.

    Objects are responsible for determining when statistics ought to be logged,
    when plans should be created, and for following the rules.

    IDEA: Look up behavior trees.
 */

(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  BSS.Agent_Model = (function(superClass) {
    extend(Agent_Model, superClass);

    function Agent_Model(scene) {
      this.scene = scene;
      this.active = null;
      this.state = null;
      this.statistics = null;
      this.navigation = null;
      this.percentage = 0;
      this.next_agent = null;
      this.representation = null;
      this.buildModel();
      this.speed = 20;
    }

    Agent_Model.prototype.buildModel = function() {
      this.statistics = new BSS.Statistics_Model();
      this.navigation = new BSS.Navigation_Model();
      this.percentage = 0;
      this.state = {};
      return this.active = false;
    };

    Agent_Model.prototype.getNavigation = function() {
      return this.navigation;
    };

    Agent_Model.prototype.getStatistics = function() {
      return this.statistics;
    };

    Agent_Model.prototype.getPercentage = function() {
      return this.percentage;
    };

    Agent_Model.prototype.getCurrentLocationAndHeading = function() {
      var path_element, path_model;
      path_model = this.navigation.getCurrentLocation();
      if (path_model !== null && path_model instanceof BSS.Path_Model) {
        path_element = path_model.getElement();
        return path_element.getLocation(this.percentage);
      }
      return this.getElement().getRepresentationLocationAndHeading();
    };

    Agent_Model.prototype.moveAlongPath = function(dt, percentages_per_meter) {
      var dPercentage;
      dPercentage = dt * this.speed * percentages_per_meter;
      this.percentage += dPercentage;
      if (this.percentage > 1.0) {
        this.percentage = 1.0;
      }
      return this.getElement().reposition();
    };

    Agent_Model.prototype.activate = function() {
      this.scene.activateObject(this);
      return this.active = true;
    };

    Agent_Model.prototype.deactivate = function() {
      this.scene.deactivateObject(this);
      return this.active = false;
    };

    Agent_Model.prototype.lookupKey = function(key) {
      return this.state[key];
    };

    Agent_Model.prototype.setKey = function(key, val) {
      this.state[key] = val;
    };

    Agent_Model.prototype.getNextAgent = function(agent) {
      return this.next_agent;
    };

    Agent_Model.prototype.setNextAgent = function(agent) {
      return this.next_agent = agent;
    };

    Agent_Model.prototype.getCurrentLocationModel = function() {
      return this.navigation.getCurrentLocation();
    };

    Agent_Model.prototype.operate = function(operator) {
      var food;
      console.log("FIXME PLEASE! Do something.");
      food = this.statistics.getFood();
      return this.statistics.setFood(food + 1);
    };

    return Agent_Model;

  })(BSS.Model);

}).call(this);