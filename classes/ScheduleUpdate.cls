global class ScheduleUpdate implements Schedulable{
    
	global void execute(SchedulableContext ctx) {
        ImageService callUpdate = new ImageService();
        callUpdate.updateDatabase();
    }
}