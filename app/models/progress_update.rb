class ProgressUpdate < ApplicationRecord
    belongs_to :proposal
    enum :rating, { no_progress: 0, unsatisfactory: 1, satisfactory: 2 , excellent: 3}
end
