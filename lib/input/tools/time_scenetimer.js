// Generated by CoffeeScript 1.11.1

/*
Written by Bryce Summers on Mar.21.2018
Sends time update commands to all of the places.
 */

(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  EX.TimeTool_SceneTimer = (function(superClass) {
    extend(TimeTool_SceneTimer, superClass);

    function TimeTool_SceneTimer(scene, camera) {
      this.scene = scene;
      this.camera = camera;
    }

    TimeTool_SceneTimer.prototype.time = function(dt) {
      dt = dt / 1000;
      return this.scene.time(dt);
    };

    TimeTool_SceneTimer.prototype.isIdle = function() {
      return true;
    };

    TimeTool_SceneTimer.prototype.finish = function() {};

    return TimeTool_SceneTimer;

  })(EX.I_Tool_Controller);

}).call(this);
