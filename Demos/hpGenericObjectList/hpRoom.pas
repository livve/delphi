unit hpRoom;

interface

uses
  Classes,
  hpGenericObjectList;

type
  ///	<summary>Room class for use with the ThpGenericObjectList</summary>
  ThpRoom = class(ThpGenericObject)
  public
    ///	<summary>Alias for the Identifier property</summary>
    ///	<value>Item identifier</value>
    property Room: string read FIdentifier;
  end;

implementation

{ ThpRoom }

end.

