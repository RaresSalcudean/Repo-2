module Dashing
  class WidgetsController < ApplicationController

    before_action :check_accessibility, only: :update
    before_action :check_widget_name,   only: [:show, :update]
    before_action :prepend_view_paths,  only: :show

    rescue_from ActionView::MissingTemplate, with: :template_not_found

    def show
      render file: widget_path, layout: false
    end

    def update
      binding.pry
      data = params[:widget] || {}
      hash = data.merge(id: params[:name], updatedAt: Time.now.utc.to_i)
      Dashing.redis.publish("#{Dashing.config.redis_namespace}.create", hash.to_json)

      render nothing: true
    end

    private

    def check_widget_name
      raise 'bad widget name' unless params[:name] =~ /\A[a-zA-z0-9_\-]+\z/
    end

    def widget_path
      params[:name]
    end

    def prepend_view_paths
      prepend_view_path main_app_view_path
    end

    def main_app_view_path
      Dashing.config.widgets_views_path
    end

    def template_not_found
      raise "Count not find template for widget #{params[:name]}. Define your widget in #{main_app_view_path}"
    end

  end
end
