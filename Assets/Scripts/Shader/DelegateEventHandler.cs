using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DelegateEventHandler : MonoBehaviour
{

    public delegate void PlayerFindEvent(Vector3 playerPosition);
  
    class Enemy
    {
        public event PlayerFindEvent OnPlayerFind; //공유할 이벤트

        public void Find(Vector3 playerPosition)
        {
            OnPlayerFind.Invoke(playerPosition);
        }
    }



}
