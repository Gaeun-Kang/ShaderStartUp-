using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;

public class Action : MonoBehaviour
{

    //랜덤 아이템 

    private string[] items = { "gun", "Trash", "Magic Card", "Book", "" };
    private Func<string> GetRandomItem;

    private void Start()
    {
        GetRandomItem = () => items[UnityEngine.Random.Range(0, items.Length)];
        string item = GetRandomItem();
        Debug.Log("You Get " + item);
    }


}
