import 'dart:io';

import 'package:cop1/ui/common/loading_widget.dart';
import 'package:cop1/ui/events/ticket_option.dart';
import 'package:cop1/utils/cop1_event.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';

import '../../data/session_data.dart';
import '../../utils/connected_widget_state.dart';
import '../../utils/ticket.dart';
import '../common/socket_exception_widget.dart';
import '../common/unknown_error_widget.dart';

class TicketPicker extends StatefulWidget {
  const TicketPicker({Key? key, required this.event}) : super(key: key);
  final Cop1Event event;

  @override
  State<TicketPicker> createState() => _TicketPickerState();

  static Dialog buildTicketDialog(BuildContext context, Cop1Event event){
    return Dialog(
        child: SizedBox(
          height: MediaQuery.of(context).size.height*0.8,
          width: MediaQuery.of(context).size.width*0.8,
          child: TicketPicker(event: event),
        )
    );
  }
}

class _TicketPickerState extends State<TicketPicker> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: session(context).getTickets(widget.event.id),
        builder: (BuildContext ctxt, AsyncSnapshot<List<Ticket>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            if (snapshot.hasError) {
              if (snapshot.error is SocketException) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                  ConnectedWidgetState.displayConnectionAlert(ctxt);
                });
                return SocketExceptionWidget(callBack: (ctx) {
                  setState(() {});
                });
              }
              Sentry.captureException(snapshot.error, stackTrace: snapshot.stackTrace);
              return UnknownErrorWidget(callBack: (ctx) {
                setState(() {});
              });
            }
            else if (snapshot.data!=null){
              return _buildWidget(ctxt, snapshot.data!);
            }
            else {
              return _buildWidget(ctxt, []);
            }
          }
          else {
            return const LoadingWidget();
          }
        }
    );
  }

  Widget _buildWidget(BuildContext context, List<Ticket> tickets){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5)
      ),
      child: Column(
        children: [
          _buildTitle(context),
          Expanded(
              child: ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (BuildContext bContext, int index) {
                  return TicketOption(event: widget.event, ticket: tickets[index]);
                },
              )
          )
        ],
      )
    );
  }

  Widget _buildTitle(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child : Center(
        child: Text(
          "Choose your time of selection",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      )
    );
  }
}