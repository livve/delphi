unit hpUserInfo;

(**
 * @copyright Copyright (C) 2011-2014, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  VCL
 * @package   hpUserInfo
 * @version   1.00
 *)

(**
 * History
 *
 * V1.00
 * - Initial release
 *)

interface

uses
  Classes, ComCtrls,
  hpGenericObjectList;

type
  ///	<summary>User class for use with the ThpGenericObjectList</summary>
  ThpUserInfo = class(ThpGenericObject)
  public
    ///	<summary>Alias for the Identifier property</summary>
    ///	<value>User name</value>
    property User: string read FIdentifier;

    ///	<summary>Alias for the Description property</summary>
    ///	<value>Room name</value>
    property RoomName: string read FDescription write FDescription;
  end;

implementation

{ ThpUserInfo }

end.

