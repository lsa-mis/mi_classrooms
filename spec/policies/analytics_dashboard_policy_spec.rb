# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnalyticsDashboardPolicy do
  subject(:policy) { described_class.new(user, :analytics_dashboard) }

  describe 'viewer access' do
    let(:user) do
      build_stubbed(:user).tap do |viewer|
        viewer.membership = ['mi-classrooms-non-admin-staging']
        viewer.admin = false
      end
    end

    it 'denies dashboard index and refresh' do
      expect(policy.index?).to be(false)
      expect(policy.refresh?).to be(false)
    end
  end

  describe 'admin access' do
    let(:user) do
      build_stubbed(:user).tap do |admin|
        admin.membership = ['mi-classrooms-admin-staging']
        admin.admin = true
      end
    end

    it 'allows dashboard index and refresh' do
      expect(policy.index?).to be(true)
      expect(policy.refresh?).to be(true)
    end
  end
end
