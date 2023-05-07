import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    Key? key,
    required this.title,
    required this.iconData,
    required this.colorIcon,
    required this.timeStart,
    required this.check,
    required this.iconBGColor,
    required this.onChanged,
    required this.index,
    required this.completed,
    required this.timeFinish,
    required this.dateFinish,
    required this.protected,
    required this.description,
    required this.isDeleted,
    required this.timeDelete,
    required this.Pinned,
  }) : super(key: key);

  final String title;
  final IconData iconData;
  final Color colorIcon;
  final String timeStart;
  final bool check;
  final Color iconBGColor;
  final Function onChanged;
  final int index;
  final bool completed;
  final bool protected;
  final String timeFinish;
  final String dateFinish;
  final String description;
  final bool isDeleted;
  final String timeDelete;
  final bool Pinned;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Theme(
              child: Transform.scale(
                scale: 1.5,
                child: Checkbox(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  side: BorderSide(
                    color: Color.fromARGB(
                        255, 156, 160, 164), // Màu sắc đường viền checkbox
                    width: 2.0,
                  ),
                  activeColor: Color(0xff6cf8a9),
                  checkColor: Color.fromARGB(255, 24, 17, 14),
                  value: check,
                  onChanged: (value) {
                    onChanged(index);
                  },
                ),
              ),
              data: ThemeData(
                  primaryColor: Colors.blue,
                  unselectedWidgetColor: Color(0xff5e616))),
          Expanded(
            child: Container(
              height: 75,
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: protected
                      ? Color.fromARGB(255, 35, 70, 196)
                      : Color(0xff2a2e3d),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 15,
                      ),
                      Container(
                        height: 33,
                        width: 36,
                        decoration: BoxDecoration(
                          color: iconBGColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          iconData,
                          color: colorIcon,
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Text(title,
                            style: TextStyle(
                              color: completed ? Colors.red : Colors.white,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.5,
                            )),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_month_rounded,
                                  size: 10, color: Colors.white),
                              SizedBox(
                                width: 5,
                              ),
                              Text(dateFinish,
                                  style: TextStyle(
                                    color:
                                        completed ? Colors.red : Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                  isDeleted == true
                                      ? Icons.auto_delete
                                      : Icons.access_time_rounded,
                                  size: 10,
                                  color: Colors.white),
                              Text(
                                  isDeleted == true
                                      ? "$timeDelete"
                                      : "${timeStart} - ${timeFinish}",
                                  style: TextStyle(
                                    color:
                                        completed ? Colors.red : Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  )),
                            ],
                          ),
                          SizedBox(height: 2,),
                          Icon(
                              Pinned == true
                                  ? Icons.pin_invoke
                                  : null,
                              size: 15,
                              color: Colors.red),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }
}
