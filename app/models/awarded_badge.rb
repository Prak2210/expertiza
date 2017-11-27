class AwardedBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :participant
  NUMBER_OF_BADGES = 2
  
  GOOD_REVIEWER_BADGE_IMAGE = "<img height = 'auto' width = '50px' src='/assets/badges/goodReviewer.png'/>"
  GOOD_TEAMMATE_IMAGE = "<img height = 'auto' width = '50px' src='/assets/badges/goodTeammate.png'/>"


	def self.award(participant_id, assignment_id,score,badge_name)
		print "In AwardedBadge _____________________________"
		badge_id = Badge.get_id_from_name(badge_name)
		# assignmentBadge = AssignmentBadge.where(:badge_id => badge_id,:assignment_id => assignment_id)
		assignmentBadge = AssignmentBadge.where("badge_id = ? AND assignment_id = ?",badge_id,assignment_id)
		print assignmentBadge.empty?
		if !assignmentBadge.empty? and score.to_i >= assignmentBadge[0].threshold
			a = AwardedBadge.new(:participant_id => participant_id, :assignment_id => assignment_id, :badge_id => badge_id)
			a.save!
		end
	end

	def self.update(assignment_id)
		AwardedBadge.where(:assignment_id => assignment_id).delete_all
		participants = Participant.where("parent_id = ? AND type = ?",assignment_id,"AssignmentParticipant")
		review_grades = ReviewGrade.where(:participant_id => participants.ids)
		review_grades.each do |r|
			AwardedBadge.award(r.participant_id,assignment_id,r.grade_for_reviewer,"GoodReviewer")
		end
	end

	def self.get_teammate_review_score(participant)	
		team = participant.team
		if team.nil?
			return false
		end
		score = 0.0
	 	teammate_reviews = participant.teammate_reviews
	 	teammate_reviews.each do |teammate_review|
			score = score + (teammate_review.get_total_score.to_f/teammate_review.get_maximum_score.to_f)		
	 	end
	 	score/teammate_reviews.size*100
	end

	def self.get_badges_student_view(student_tasks)
		badge_matrix = []
		current_assignment_count = 0
		consistency_flag = true
		student_tasks.each do |student_task|
			badge_matrix.push([false] * NUMBER_OF_BADGES)
			
			badge_matrix[current_assignment_count][0] = AwardedBadge.good_reviewer(student_task.participant)
			
		  badge_matrix[current_assignment_count][1] = AwardedBadge.good_teammate(student_task.participant)
		
		  
		  current_assignment_count = current_assignment_count + 1;
		 end
		 
		 return badge_matrix
	end
	
	def self.good_reviewer(participant)
		badge = AwardedBadge.where(participant_id: participant.id, badge_id: 1)
		if !badge.empty?
				return GOOD_REVIEWER_BADGE_IMAGE.html_safe
		end
		return false
	end
	
	def self.good_teammate(participant)
		badge = AwardedBadge.where(participant_id: participant.id, badge_id: 2)
		if !badge.empty?
				return GOOD_TEAMMATE_IMAGE.html_safe
		end
		return false
	end
end
