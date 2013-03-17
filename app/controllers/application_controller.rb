# encoding: utf-8
# == License
# Ekylibre - Simple ERP
# Copyright (C) 2009 Brice Texier, Thibaud Merigon
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

class ApplicationController < ActionController::Base

  # Returns the full qualified name of a controller
  # like all/my/things
  def self.absolute_controller_name
    self.name.to_s.gsub(/Controller$/, '').underscore
  end

  def self.human_name
    ::I18n.translate("controllers." + absolute_controller_name)
  end

  def self.human_action_name(action, options = {})
    options = {} unless options.is_a?(Hash)
    root, action = "actions." + self.absolute_controller_name + ".", action.to_s
    options[:default] ||= []
    options[:default] << (root + "new").to_sym  if action == "create"
    options[:default] << (root + "edit").to_sym if action == "update"
    return ::I18n.translate(root + action, options)
  end

  def human_action_name()
    return self.class.human_action_name(action_name, @title)
  end

  def authorized?(url_options = {})
    return true if url_options == "#" or current_user.administrator?
    if url_options.is_a?(Hash)
      url_options[:controller] ||= self.class.absolute_controller_name
      url_options[:action] ||= :index
    elsif url_options.is_a?(String) and url_options.match(/\#/)
      action = url_options.split("#")
      url_options = {:controller => action[0].to_sym, :action => action[1].to_sym}
    else
      raise ArgumentError.new("Invalid URL: " + url_options.inspect)
    end
    if current_user
      raise ArgumentError.new("Uncheckable URL: " + url_options.inspect) if url_options[:controller].blank? or url_options[:action].blank?
      return current_user.authorization(url_options[:controller], url_options[:action], session[:rights]).nil?
    else
      true
    end
  end


end
