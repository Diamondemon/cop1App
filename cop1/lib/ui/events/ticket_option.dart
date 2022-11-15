import 'package:cop1/ui/events/subscribe_button.dart';
import 'package:cop1/utils/cop1_event.dart';
import 'package:flutter/material.dart';

import '../../utils/ticket.dart';

class TicketOption extends StatelessWidget {
  const TicketOption({Key? key, required this.ticket, required this.event}) : super(key: key);
  final Ticket ticket;
  final Cop1Event event;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
            horizontal: BorderSide(color: Theme.of(context).primaryColor, width:3.0)
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Column(
        children: [
          Text(ticket.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            child: SubscribeButton(
              event: event,
              ticketId: ticket.id,
              endCallback: (){Navigator.of(context).pop();}
            )
          )
        ],
      ),
    );
  }
}
