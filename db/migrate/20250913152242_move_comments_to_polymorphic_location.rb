class MoveCommentsToPolymorphicLocation < ActiveRecord::Migration[8.0]
  class Comment < ApplicationRecord
    belongs_to :location, polymorphic: true
  end

  def up
    ActiveRecord::Base.transaction do
      # there are remaining topics that start with version 0 before we changed it
      # the mismatch is making the comments not go through
      borked_topics = []

      TopicInstance.find_each do |topic_instance|
        if topic_instance.version == 0
          borked_topics << topic_instance.topic
        end
      end

      borked_topics.each do |topic|
        topic.topic_instances.each do |topic_instance|
          topic_instance.version += 1
        end
      end

      Comment.find_each do |comment|
        project_instance = ProjectInstance.find_by(project_id: comment.project_id, version: comment.project_version_number)
        topic_instance = TopicInstance.find_by(project_id: comment.project_id, version: comment.project_version_number)
        
        if project_instance
          comment.update!(location: project_instance)
        elsif topic_instance
          comment.update!(location: topic_instance)
        else
          Rails.logger.info "project_id #{comment.project_id} version: #{comment.project_version_number}"
          raise StandardError
        end
      end
    end

    change_column_null :comments, :location_type, false
    change_column_null :comments, :location_id, false
  end
end
