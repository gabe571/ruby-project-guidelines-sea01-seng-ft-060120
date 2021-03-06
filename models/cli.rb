class CLI  
    attr_accessor :user, :single_watch

    def intro
        @local_user = User.get_user_name
        main_menu
    end

    def main_menu 
        prompt = TTY::Prompt.new
        prompt.select("What would you like to do?", cycle: true, echo: false) do |menu|
            menu.choice "Create county Watch.", -> {create_single_watch}
            menu.choice "Show current county Watches.", -> {show_current_watches}
            menu.choice "Show description of Phase for a county you have a Watch on.", -> {show_phase_description}
            menu.choice "Remove county from Watches.", -> {remove_county}
            menu.choice "Exit COVID-19 WA Phase Tracker" do exit! end
            # menu.choice "Change user name", -> {change_user_name}
        end
    end
        
    def create_single_watch
        prompt = TTY::Prompt.new
        county_watch = prompt.select("To add a county Watch, use ↑/↓ arrows to scroll to county, ←/→ to change page, or letter keys to filter by letter. Press Enter/Return to select.", %w(King Pierce Snohomish Spokane Clark Thurston Kitsap Yakima Whatcom Benton Skagit Cowlitz Grant Franklin Island Lewis Clallam Chelan Grays\ Harbor Mason Walla\ Walla Whitman Kittitas Stevens Douglas Okanogan Jefferson Asotin Klickitat Pacific Adams San\ Juan Pend\ Oreille Skamania Lincoln Ferry Wahkiakum Columbia Garfield), per_page: 10, cycle: true, filter: true)
        local_county = County.find_by(county_name: county_watch)
        previous_county_watch = @local_user.single_watches.select{|single_watch| single_watch.county_id == local_county.id}
        previous_county_watch.length > 0 ? (puts "Watch already exists.") : SingleWatch.create(county_id: local_county.id, user_id: @local_user.id) && (puts "A Watch has been set on the selected county!");
        main_menu
    end

    # def gets_current_watches
    #     @current_watches = @local_user.counties.collect{|county| county.county_name + " County" + ", " + county.phase.phase_name}
    # end

    def show_current_watches
        # @current_watches.length > 0 ? (puts @current_watches) : (puts "You don't have any Watches to show right now.")
        @first_output = @local_user.counties.collect{|county| county.county_name + " County" + ", " + county.phase.phase_name}
        @first_output.count > 0 ? (puts @first_output) : (puts "You don't have any Watches to show right now.")
        main_menu
    end

    def show_phase_description
        if @first_output.count > 0
            prompt = TTY::Prompt.new
            choices = [@local_user.counties.collect{|county| county.county_name}.uniq]
            county_to_describe = prompt.select("Use ↑/↓ arrows to scroll to county, then Enter/Return to select.", choices)
            local_county = County.find_by(county_name: county_to_describe)
            phase_to_describe = Phase.select{|phase| phase.id == local_county.phase_id}
            puts phase_to_describe[0].phase_description
            main_menu
        else
            puts "You don't have a Watch on any counties right now."
        end
        main_menu
    end

    def remove_county
        if @first_output.count > 0
            prompt = TTY::Prompt.new
            choices = [@local_user.counties.collect{|county| county.county_name}.uniq]
            county_watch = prompt.select("Use ↑/↓ arrows to scroll to county or letter keys to filter by letter, then Enter/Return to select.", choices)
            local_county = County.find_by(county_name: county_watch)
            local_watch = @local_user.single_watches.select{|single_watch| single_watch.county_id == local_county.id}
            user_watches = SingleWatch.all.select(user_id: local_watch[0].user_id)
            watches_to_delete = user_watches.where(county_id: local_watch[0].county_id).delete_all
            puts "Removed county from your Watches."
        else 
            puts "You don't have any Watches to remove right now."
        end
        main_menu
    end

    # *** why did delete_all work but not destroy_all?  was it table duplicates or lack of primary id in single_watches table? ***

    # def change_user_name
    
    # end

end