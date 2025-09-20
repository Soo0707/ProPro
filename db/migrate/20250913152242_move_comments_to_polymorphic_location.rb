class MoveCommentsToPolymorphicLocation < ActiveRecord::Migration[8.0]
  class Comment < ApplicationRecord
    belongs_to :location, polymorphic: true
  end

  def up
    ActiveRecord::Base.transaction do
      Comment.find_each do |comment|
        project_instance = ProjectInstance.find_by(project_id: comment.project_id, version: comment.project_version_number)
        topic_instance = TopicInstance.find_by(project_id: comment.project_id, version: comment.project_version_number)
        
        if project_instance
          comment.update!(location: project_instance)
        elsif topic_instance
          comment.update!(location: topic_instance)
        else
          Rails.logger.info "project_id #{comment.project_id} version: #{comment.project_version_number}"
          Rails.logger.info "project_instance: #{project_instance.inspect}, topic_instance: #{topic_instance.inspect}"
          raise StandardError
        end
      end
    end

    change_column_null :comments, :location_type, false
    change_column_null :comments, :location_id, false
  end
end
