require 'rails_helper'

feature 'index page' do
  context 'when visiting as a student' do
    let(:student) { FactoryGirl.create(:user) }
    before { sign_in student }

    scenario 'shows all assessments' do
      first_assessment = FactoryGirl.create(:assessment)
      second_assessment = FactoryGirl.create(:assessment, title: 'another_assessment')
      visit assessments_path
      expect(page).to have_content first_assessment.title
      expect(page).to have_content second_assessment.title
    end

    # these two tests will require some extra model methods to determine the
    # if the student has submitted an assessment or not.
    xscenario 'shows if the student has submitted an assessment' do
      assessment = FactoryGirl.create(:assessment)
      FactoryGirl.create(:submission, assessment: assessment, user: student)
      visit assessments_path
      expect(page).to have_content 'Submitted'
      expect(page).to_not have_content 'Not submitted'
    end

    xscenario 'shows if the assessment has been graded' do
      assessment = FactoryGirl.create(:assessment)
      submission = FactoryGirl.create(:submission, assessment: assessment, user: student)
      FactoryGirl.create(:review, submission: submission)
      visit assessments_path
      expect(page).to have_content 'Graded'
      expect(page).to_not have_content 'Submitted'
    end

    scenario 'links to assessment show page' do
      assessment = FactoryGirl.create(:assessment_with_requirements)
      visit assessments_path
      click_link assessment.title
      expect(page).to have_content assessment.title
      expect(page).to have_content assessment.requirements.first.content
    end
  end
end

feature 'show page' do
  context 'when visiting as a student' do
    let(:student) { FactoryGirl.create(:user) }
    let(:assessment) { FactoryGirl.create(:assessment) }
    before { sign_in student }
    subject { page }

    context 'before submitting' do
      before do
        visit assessment_path(assessment)
      end

      it { is_expected.to have_button 'Submit' }
      it { is_expected.to_not have_content 'pending review' }
      it { is_expected.to_not have_link 'has been reviewed' }

    end

    context 'when submitting' do
      before do
        visit assessment_path(assessment)
      end

      scenario 'with valid input' do
        fill_in 'submission_link', with: 'http://github.com'
        click_button 'Submit'
        is_expected.to have_content 'Thank you for submitting'
      end

      scenario 'with invalid input' do
        click_button 'Submit'
        is_expected.to have_content "can't be blank"
      end
    end

    context 'after having submitted' do
      before do
        FactoryGirl.create(:submission, assessment: assessment, user: student)
        visit assessment_path(assessment)
      end

      it { is_expected.to have_button 'Resubmit' }
      it { is_expected.to have_content 'pending review' }
      it { is_expected.to_not have_link 'has been reviewed' }
    end

    context 'after submission has been reviewed' do
      let(:submission) { FactoryGirl.create(:submission, assessment: assessment, user: student) }

      before do
        FactoryGirl.create(:review, submission: submission)
        visit assessment_path(assessment)
      end

      it { is_expected.to_not have_content 'pending review' }
      it { is_expected.to have_link 'has been reviewed' }
    end

    context 'after resubmitting' do
      let(:submission) { FactoryGirl.create(:submission, assessment: assessment, user: student) }

      before do
        FactoryGirl.create(:review, submission: submission)
        visit assessment_path(assessment)
        click_on 'Resubmit'
      end

      it { is_expected.to have_content 'Submission updated' }
      it { is_expected.to have_content 'pending review' }
      it { is_expected.to_not have_link 'has been reviewed' }
    end
  end
end
