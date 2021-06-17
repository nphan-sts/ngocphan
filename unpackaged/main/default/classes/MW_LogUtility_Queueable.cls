/**
 * Main Queueable Logging class for sending data to wherever logs need to be sent (for example, DataDog.)
 * This will take a collection of information to log out, to make it easier to track
 *  information down.
 */

public class MW_LogUtility_Queueable implements Queueable {
	public class Log {
		public String apexClass;
		public String label;
		public String message;
		public String type;
	}

	private MW_LogUtility_Queueable.Log log;
	public MW_LogUtility_Queueable(MW_LogUtility_Queueable.Log log) {
		this.log = log;
	}

	public void execute(QueueableContext context) {
		MW_DataDogCallOut.send(log);
	}
}