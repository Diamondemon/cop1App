import 'package:flutter/material.dart';

class EventTile extends StatefulWidget {
  const EventTile({Key? key, required this.event}) : super(key: key);
  final Map<String, dynamic> event;

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height/4,
        decoration: BoxDecoration(
          border: Border.symmetric(
              horizontal: BorderSide(color: Theme.of(context).primaryColor, width:3.0)
          ),
        ),
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, right:10.0, left:10.0),
        child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.event["title"]),
                    const Spacer(),
                    Image.network(widget.event['img'], fit: BoxFit.fill, height: MediaQuery.of(context).size.height/7),
                    const Spacer(),
                  ]
                )
              ),
              Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Calendrier"),
                      TextButton(onPressed: _addToCalendar, child:Text(widget.event["date"])),
                      const Spacer(),
                      const Text("Lieu"),
                      TextButton(onPressed: _lookOnMaps, child:Text(widget.event["loc"])),
                      const Spacer(),
                      Center(
                        child: RawMaterialButton(
                          onPressed: _participate,
                          fillColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Text("Je m'inscris"),
                        ),
                      )
                    ]
                  )
              )
            ]
        )
    );
  }

  void _participate(){

  }

  void _addToCalendar(){

  }

  void _lookOnMaps(){

  }

}
