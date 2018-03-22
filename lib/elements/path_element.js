// Generated by CoffeeScript 1.11.1
(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  BSS.Path_Element = (function(superClass) {
    extend(Path_Element, superClass);

    function Path_Element(mid_line) {
      Path_Element.__super__.constructor.call(this, new BSS.Path_Model());
      this.mid_line = mid_line;
      this.partial_distances = this.mid_line.computeCumulativeLengths();
      this.getModel().setTransversalLength(this.partial_distances[this.partial_distances.length - 1]);
      this.tangent_angles = this.mid_line.computeTangentAngles();
      this.tangent_angles.push(this.tangent_angles[this.tangent_angles.length - 1]);
      this.buildFromConfiguration();
    }


    /* Representation building from path mathmatics. */

    Path_Element.prototype.buildFromConfiguration = function() {
      var container, path_visual;
      container = this._visualRep;
      container.clearVisuals();
      path_visual = EX.Visual_Factory.newPath(this.mid_line, EX.style.radius_path_default, EX.style.c_road_fill, true);
      container.addVisual(path_visual);
    };


    /* Element Interface. */

    Path_Element.prototype.getLocation = function(percentage) {
      var ang0, ang1, highest_le_index, i0, i1, len, location, partial_distance, pd0, pd1, per, pt0, pt1, tangent, tangent_angle, tx, ty;
      partial_distance = percentage * this.getModel().getTransversalLength();
      highest_le_index = BDS.Arrays.binarySearch(this.partial_distances, partial_distance, function(a, b) {
        return a <= b;
      });
      len = this.mid_line.size();
      i0 = highest_le_index;
      if (i0 === len - 1) {
        i0 = len - 2;
      }
      i1 = i0 + 1;
      pd0 = this.partial_distances[i0];
      pd1 = this.partial_distances[i1];
      per = (partial_distance - pd0) / (pd1 - pd0);
      pt0 = this.mid_line.getPoint(i0);
      pt1 = this.mid_line.getPoint(i1);
      ang0 = this.tangent_angles[i0];
      ang1 = this.tangent_angles[i1];
      tangent_angle = BDS.Math.lerp(ang0, ang1, per);
      location = pt0.multScalar(1.0 - per).add(pt1.multScalar(per));
      tx = Math.cos(tangent_angle);
      ty = Math.sin(tangent_angle);
      tangent = new BDS.Point(tx, ty);
      return [location, tangent];
    };

    Path_Element.prototype.addAgent = function(agent) {
      var path_model;
      path_model = this.getModel();
      return path_model.enqueueAgent(agent.getModel());
    };

    Path_Element.prototype.addOperator = function(operator, percentage) {
      var path_model;
      path_model = this.getModel();
      return path_model.addOperator(operator, percentage);
    };


    /* Inputs */

    Path_Element.prototype.time = function(dt) {
      return this.getModel().moveAgents(dt);
    };

    return Path_Element;

  })(BSS.Element);

}).call(this);