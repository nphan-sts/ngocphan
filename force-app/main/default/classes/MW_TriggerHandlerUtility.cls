//This is a utitliy class that can be used to help manage triggers.
// For each object, create 1 "Master" Trigger that can handle each event.  Then for each peice of funcitonality,
// create a class and implement "TriggerHandler.HandlerInterface".  Write all the trigger logic in the "void handle()"
// method just as you would directly in a trigger.  The one difference is that Trigger.new and Trigger.old must be explicitly cast to the concrete SOBJECT
// EX:
//  * for(System__c sys : (List<System__c>) trigger.new){}
//  * Account old = (Account) trigger.old[i];
//In the master trigger:
// 1: Instante a new Trigger Handler Obj: TriggerHandler handler = new TriggerHandler();
// 2: Bind any logic to the desired events: handler.bind(TriggerHandler.Evt.beforeupdate, new MyHandlerClass());
//   Make sure that the event bound is executed by the trigger!!!
// 3: call manage: handler.manage();
public class MW_TriggerHandlerUtility
{
	/**
	 *   Enum representing each of before/after CRUD events on Sobjects
	 */
	public enum Evt
	{
		afterdelete, afterinsert, afterundelete,
		afterupdate, beforedelete, beforeinsert, beforeupdate
	}

	/*
	 *   Simplistic handler to implement on any of the event. It doesn't require or enforces any pattern except the
	 *   method name to be "handle()".
	 */
	public interface HandlerInterface
	{
		void handle();
	}

	// Internal mapping of handlers
	Map<String, List<HandlerInterface>> eventHandlerMapping = new Map<String, List<HandlerInterface>>();

	/**
	 *   Core API to bind handlers with events
	 */
	public MW_TriggerHandlerUtility bind(Evt event, HandlerInterface eh)
	{
		List<HandlerInterface> handlers = eventHandlerMapping.get(event.name());
		if (handlers == null)
		{
			handlers = new List<HandlerInterface>();
			eventHandlerMapping.put(event.name(), handlers);
		}
		handlers.add(eh);
		return this;
	}

	/**
	 *   Invokes correct handlers as per the context of Trigger and available registered handlers
	 */
	public void manage()
	{
		Evt ev = null;
		if(Trigger.isInsert && Trigger.isBefore)
		{
			ev = Evt.beforeinsert;
		}
		else if(Trigger.isInsert && Trigger.isAfter)
		{
			ev = Evt.afterinsert;
		}
		else if(Trigger.isUpdate && Trigger.isBefore)
		{
			ev = Evt.beforeupdate;
		}
		else if(Trigger.isUpdate && Trigger.isAfter)
		{
			ev = Evt.afterupdate;
		}
		else if(Trigger.isDelete && Trigger.isBefore)
		{
			ev = Evt.beforedelete;
		}
		else if(Trigger.isDelete && Trigger.isAfter)
		{
			ev = Evt.afterdelete;
		}
		else if(Trigger.isundelete)
		{
			ev = Evt.afterundelete;
		}

		List<HandlerInterface> handlers = eventHandlerMapping.get(ev.name());

		if (handlers != null && !handlers.isEmpty())
		{
			for (HandlerInterface h : handlers)
			{
				h.handle();
			}
		}
	}
}