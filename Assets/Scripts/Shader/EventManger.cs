using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EventManger : MonoBehaviour
{
    public delegate void PlayerFindEvent(Vector3 playerposition);
    public static event PlayerFindEvent OnPlayerFind;

    public static void FindPlayerEvent(Vector3 playerposition)
    {
        OnPlayerFind.Invoke(playerposition);
    }    

}
